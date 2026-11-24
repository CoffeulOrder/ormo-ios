import Foundation

struct OrderNotFoundError: Error {}

struct MockOrderRepository: OrderRepository {
    func fetchOrder(pickupNumber: Int, storeName: String) async throws -> Order {
        guard let order = LocalStore.shared.order(pickupNumber: pickupNumber, storeName: storeName) else {
            throw OrderNotFoundError()
        }
        return order
    }
}

extension Order {
    // OrderDetailViewModel이 실제 주문을 받아오기 전까지 잠깐 보여줄 자리표시자, 그리고 Preview 전용.
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
