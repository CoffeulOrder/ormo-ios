import Foundation

// 홈 화면 상단 "진행 중인 주문" 구역. 1초마다 들여다보던 Mock과 달리 실서버는 폴링 간격을
// 넉넉히 둔다. 목록 API(필터=ACTIVE)는 대기 건수(aheadCount)를 안 줘서, 후보로 추린 주문마다
// 상세를 한 번씩 더 불러온다(최대 3건이라 부담은 적다).
struct RemoteLiveOrderRepository: LiveOrderRepository {
    private static let pollIntervalSeconds: UInt64 = 5
    private static let maxVisibleOrders = 3
    private static let pickupWindowMinutes = 20

    private struct OrderListItemData: Decodable {
        let orderId: Int
        let storeName: String
        let status: String
        let pickupNo: Int?
    }

    private struct OrderListData: Decodable {
        let content: [OrderListItemData]
    }

    private struct TimelineData: Decodable {
        let readyAt: String?
    }

    private struct OrderDetailData: Decodable {
        let aheadCount: Int
        let timeline: TimelineData
    }

    private static let pickupTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    func observeLiveOrders(storeName: String) -> AsyncStream<[LiveOrder]> {
        AsyncStream { continuation in
            let task = Task {
                var lastSignature = ""
                while !Task.isCancelled {
                    let liveOrders = (try? await Self.currentLiveOrders(storeName: storeName)) ?? []
                    let signature = liveOrders
                        .map { "\($0.orderId)-\($0.stage)-\($0.queueCount)-\($0.pickupDeadlineText)" }
                        .joined(separator: "|")
                    if signature != lastSignature {
                        continuation.yield(liveOrders)
                        lastSignature = signature
                    }
                    try? await Task.sleep(for: .seconds(Self.pollIntervalSeconds))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func currentLiveOrders(storeName: String) async throws -> [LiveOrder] {
        let endpoint = Endpoint(
            method: .get,
            path: "/api/v1/orders",
            queryItems: [URLQueryItem(name: "filter", value: "ACTIVE"), URLQueryItem(name: "size", value: "50")]
        )
        let list: OrderListData = try await APIClient.shared.send(endpoint, decodingDataAs: OrderListData.self)
        let candidates = list.content.filter { $0.storeName == storeName }.prefix(maxVisibleOrders)

        return await withTaskGroup(of: LiveOrder?.self) { group in
            for item in candidates {
                group.addTask { await liveOrder(from: item) }
            }
            var results: [LiveOrder] = []
            for await result in group {
                if let result { results.append(result) }
            }
            return results
        }
    }

    private static func liveOrder(from item: OrderListItemData) async -> LiveOrder? {
        let stage: OrderStage
        switch item.status {
        case "REQUESTED", "ACCEPTED": stage = .confirming
        case "MAKING": stage = .making
        case "READY": stage = .readyForPickup
        default: return nil
        }

        let detailEndpoint = Endpoint(method: .get, path: "/api/v1/orders/\(item.orderId)")
        guard let detail = try? await APIClient.shared.send(detailEndpoint, decodingDataAs: OrderDetailData.self) else { return nil }

        var pickupDeadlineText = ""
        if stage == .readyForPickup, let readyAt = APIDateParsing.date(detail.timeline.readyAt) {
            let deadline = Calendar.current.date(byAdding: .minute, value: pickupWindowMinutes, to: readyAt) ?? readyAt
            pickupDeadlineText = "\(pickupTimeFormatter.string(from: deadline))까지 받아주세요"
        }

        return LiveOrder(
            orderId: item.orderId,
            pickupNumber: item.pickupNo ?? 0,
            storeName: item.storeName,
            stage: stage,
            queueCount: detail.aheadCount,
            pickupDeadlineText: pickupDeadlineText
        )
    }
}
