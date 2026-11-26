import Foundation

// 홈 화면 상단의 "진행 중인 주문" 구역. LocalStore에 실제로 진행 중(픽업 전)인 주문이 있으면 그 상태를
// 보여주고, 없으면(또는 픽업·취소로 끝나면) 사라진다. 최대 3건까지만 보여준다(먼저 접수된 순).
// OrderDetailViewModel이나 MockOrderProgressionScheduler가 다른 화면에서 상태를 바꾸므로, 1초
// 간격으로 LocalStore를 들여다봐서 바뀐 게 있을 때만 새로 내보낸다.
struct MockLiveOrderRepository: LiveOrderRepository {
    private static let terminalStatuses: Set<OrderStatus> = [.pickedUp, .cancelled, .userCancelled, .refunded, .unclaimed]
    private static let maxVisibleOrders = 3

    func observeLiveOrders(storeName: String) -> AsyncStream<[LiveOrder]> {
        AsyncStream { continuation in
            let task = Task {
                // 빈 배열의 signature는 ""(nil이 아니다) — 시작값도 똑같이 ""로 둬야 "주문이
                // 하나도 없는 채로 그대로"인 첫 번째 확인에서 괜히 빈 배열을 또 내보내지 않는다.
                // (Preview에서 이 화면에 미리 주문을 심어둬도, 관찰 루프가 1초 뒤 빈 배열로
                // 덮어써버리는 버그가 있었다.)
                var lastSignature = ""
                while !Task.isCancelled {
                    let liveOrders = Self.currentLiveOrders(storeName: storeName)
                    let signature = liveOrders
                        .map { "\($0.pickupNumber)-\($0.stage)-\($0.queueCount)-\($0.pickupDeadlineText)" }
                        .joined(separator: "|")
                    if signature != lastSignature {
                        continuation.yield(liveOrders)
                        lastSignature = signature
                    }
                    try? await Task.sleep(for: .seconds(1))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func currentLiveOrders(storeName: String) -> [LiveOrder] {
        let orders = LocalStore.shared.orders
            .filter { $0.storeName == storeName && !terminalStatuses.contains($0.status) }
            // 먼저 접수된 주문이 먼저 끝날 가능성이 높으니, 맨 앞(대표)으로 둔다.
            .sorted { $0.confirmedAt < $1.confirmedAt }
            .prefix(maxVisibleOrders)

        return orders.compactMap { order in
            // 앱을 껐다 켰거나 주문 상세를 한 번도 안 연 경우에도 진행되도록, 홈 화면이 들여다볼 때마다
            // 걸어준다 — 이미 진행 중이면 scheduleIfNeeded가 아무것도 하지 않는다.
            MockOrderProgressionScheduler.shared.scheduleIfNeeded(for: order)

            let stage: OrderStage
            let queueCount: Int
            let pickupDeadlineText: String
            switch order.status {
            case .confirming:
                stage = .confirming
                queueCount = 3
                pickupDeadlineText = ""
            case .making:
                stage = .making
                queueCount = 2
                pickupDeadlineText = ""
            case .waitingPickup:
                stage = .readyForPickup
                queueCount = 0
                pickupDeadlineText = "13:30까지 받아주세요"
            case .cancelled, .pickedUp, .userCancelled, .refunded, .unclaimed:
                return nil
            }

            return LiveOrder(pickupNumber: order.pickupNumber, storeName: order.storeName, stage: stage, queueCount: queueCount, pickupDeadlineText: pickupDeadlineText)
        }
    }
}
