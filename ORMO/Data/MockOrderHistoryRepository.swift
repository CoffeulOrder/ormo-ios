import Foundation

struct MockOrderHistoryRepository: OrderHistoryRepository {
    func fetchOrderHistory() async throws -> [Order] {
        try? await Task.sleep(for: .seconds(0.3))

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) ?? today

        return [
            Order(
                pickupNumber: 103,
                storeName: "범석관 카페",
                status: .pickedUp,
                items: [
                    OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가"),
                    OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가")
                ],
                subtotalPrice: 3000,
                paymentMethod: .card,
                paidAt: today,
                confirmedAt: today,
                pickedUpAt: today
            ),
            Order(
                pickupNumber: 102,
                storeName: "범석관 카페",
                status: .cancelled,
                items: [
                    OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가")
                ],
                subtotalPrice: 3000,
                paymentMethod: .card,
                paidAt: yesterday,
                confirmedAt: yesterday
            ),
            Order(
                pickupNumber: 101,
                storeName: "범석관 카페",
                status: .pickedUp,
                items: [
                    OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가")
                ],
                subtotalPrice: 3000,
                paymentMethod: .card,
                paidAt: twoDaysAgo,
                confirmedAt: twoDaysAgo,
                pickedUpAt: twoDaysAgo
            )
        ]
    }
}
