import Foundation

struct MockOrderRepository: OrderRepository {
    func fetchOrder(pickupNumber: Int, storeName: String) async throws -> Order {
        .mock(pickupNumber: pickupNumber, storeName: storeName)
    }
}

extension Order {
    static func mock(pickupNumber: Int, storeName: String) -> Order {
        let now = Date()
        return Order(
            pickupNumber: pickupNumber,
            storeName: storeName,
            status: .confirming,
            items: [
                OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가"),
                OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가")
            ],
            subtotalPrice: 3000,
            paymentMethod: .card,
            paidAt: now,
            confirmedAt: now
        )
    }
}
