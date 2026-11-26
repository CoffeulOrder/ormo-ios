import Foundation

@Observable
final class PaymentProcessingViewModel {
    let orderId: Int
    let paymentMethod: PaymentMethod
    let totalPrice: Int
    let storeName: String
    var outcome: PaymentOutcome?
    // 결제 성공 시 받아온 주문의 픽업 번호. 주문 완료 화면에 넘겨준다.
    private(set) var completedOrderPickupNumber: Int?

    let pgOrderId: String
    private let cart: CartStore
    private let orderRepository: OrderRepository
    private let paymentRepository: PaymentRepository

    init(
        orderId: Int,
        pgOrderId: String,
        paymentMethod: PaymentMethod,
        totalPrice: Int,
        storeName: String,
        cart: CartStore,
        orderRepository: OrderRepository = AppContainer.shared.orderRepository,
        paymentRepository: PaymentRepository = AppContainer.shared.paymentRepository
    ) {
        self.orderId = orderId
        self.pgOrderId = pgOrderId
        self.paymentMethod = paymentMethod
        self.totalPrice = totalPrice
        self.storeName = storeName
        self.cart = cart
        self.orderRepository = orderRepository
        self.paymentRepository = paymentRepository
    }

    func submit() async {
        let previousFailureCount = cart.paymentFailureCount
        let result = (try? await paymentRepository.confirmPayment(
            orderId: orderId,
            pgOrderId: pgOrderId,
            method: paymentMethod,
            totalPrice: totalPrice,
            previousFailureCount: previousFailureCount
        )) ?? .failure

        switch result {
        case .success:
            let order = try? await orderRepository.fetchOrder(orderId: orderId)
            cart.clearAfterSuccessfulPayment()
            completedOrderPickupNumber = order?.pickupNumber ?? 0
        case .failure:
            cart.recordPaymentFailure()
        case .expired:
            break
        }
        outcome = result
    }
}
