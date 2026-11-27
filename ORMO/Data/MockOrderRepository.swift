import Foundation

struct OrderNotFoundError: Error {}

// Mock 세계에는 진짜 "결제 대기" 구간이 없어 생성과 동시에 완성된 주문을 만든다(결제 확인은
// MockPaymentRepository가 성공/실패만 흉내 낸다).
struct MockOrderRepository: OrderRepository {
    func createOrder(
        storeId: String,
        storeName: String,
        items: [CartLineItem],
        paymentMethod: PaymentMethod,
        withdrawalLimitAgreed: Bool
    ) async throws -> CreatedOrder {
        try? await Task.sleep(for: .seconds(0.2))

        let orderId = LocalStore.shared.nextOrderId()
        let pickupNumber = LocalStore.shared.nextPickupNumber()
        let now = Date()
        let order = Order(
            orderId: orderId,
            storeId: storeId,
            pickupNumber: pickupNumber,
            storeName: storeName,
            status: .confirming,
            items: items.map { OrderItem(name: $0.menuItemName, quantity: $0.quantity, optionsSummary: $0.optionsSummary) },
            subtotalPrice: items.reduce(0) { $0 + $1.totalPrice },
            paymentMethod: paymentMethod,
            paidAt: now,
            confirmedAt: now
        )
        LocalStore.shared.addOrder(order)
        return Self.mockCreatedOrder(orderId: orderId, amount: order.subtotalPrice)
    }

    // Mock은 실제 PortOne 결제창을 띄우지 않아(AppConfig.useMock이면 CartView가 바로
    // paymentProcessing으로 보낸다) 이 값들은 실제로 쓰이지 않는다. 타입만 맞춰준다.
    private static func mockCreatedOrder(orderId: Int, amount: Int) -> CreatedOrder {
        CreatedOrder(
            orderId: orderId,
            portOneStoreId: "mock-store",
            channelKey: "mock-channel",
            paymentId: "mock-payment-\(orderId)",
            currency: "KRW",
            orderName: "Mock 주문",
            amount: amount
        )
    }

    func retryPaymentAttempt(orderId: Int) async throws -> CreatedOrder {
        guard let order = LocalStore.shared.order(orderId: orderId) else {
            throw OrderNotFoundError()
        }
        return Self.mockCreatedOrder(orderId: orderId, amount: order.subtotalPrice)
    }

    func fetchOrder(orderId: Int) async throws -> Order {
        guard let order = LocalStore.shared.order(orderId: orderId) else {
            throw OrderNotFoundError()
        }
        MockOrderProgressionScheduler.shared.scheduleIfNeeded(for: order)
        return order
    }

    func cancelOrder(orderId: Int, reason: String?) async throws {
        guard var order = LocalStore.shared.order(orderId: orderId) else {
            throw OrderNotFoundError()
        }
        order.status = .userCancelled
        order.userCancelledAt = Date()
        LocalStore.shared.updateOrder(order)
    }

    func fetchActiveOrderCount() async throws -> Int {
        let ongoingStatuses: Set<OrderStatus> = [.confirming, .making, .waitingPickup]
        return LocalStore.shared.orders.filter { ongoingStatuses.contains($0.status) }.count
    }
}
