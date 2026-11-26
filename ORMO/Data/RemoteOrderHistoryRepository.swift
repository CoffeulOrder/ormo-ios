import Foundation

struct RemoteOrderHistoryRepository: OrderHistoryRepository {
    private struct OrderListItemData: Decodable {
        let orderId: Int
    }

    private struct OrderListData: Decodable {
        let content: [OrderListItemData]
    }

    func fetchOrderHistory() async throws -> [Order] {
        let endpoint = Endpoint(
            method: .get,
            path: "/api/v1/orders",
            queryItems: [URLQueryItem(name: "filter", value: "HISTORY"), URLQueryItem(name: "size", value: "20")]
        )
        let list: OrderListData = try await APIClient.shared.send(endpoint, decodingDataAs: OrderListData.self)

        // 목록 응답엔 아이템 배열이 없어(요약 문자열뿐), 주문별 상세를 병렬로 받아 합친다.
        // 상세 조회 하나가 실패해도 나머지 내역은 그대로 보여준다.
        let orderRepository = RemoteOrderRepository()
        return await withTaskGroup(of: (Int, Order?).self) { group in
            for item in list.content {
                group.addTask {
                    (item.orderId, try? await orderRepository.fetchOrder(orderId: item.orderId))
                }
            }
            var ordered: [(Int, Order)] = []
            for await (orderId, order) in group {
                if let order { ordered.append((orderId, order)) }
            }
            let order = list.content.map(\.orderId)
            return ordered.sorted { order.firstIndex(of: $0.0) ?? 0 < order.firstIndex(of: $1.0) ?? 0 }.map(\.1)
        }
    }
}
