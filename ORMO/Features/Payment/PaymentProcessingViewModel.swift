import Foundation

@Observable
final class PaymentProcessingViewModel {
    let paymentMethod: PaymentMethod
    let totalPrice: Int
    let storeName: String
    var outcome: PaymentOutcome?
    // 결제 성공 시 발급되는 픽업 번호. 주문 완료 화면에 넘겨준다.
    private(set) var completedOrderPickupNumber: Int?

    private let cart: CartStore
    private let paymentRepository: PaymentRepository

    init(
        paymentMethod: PaymentMethod,
        totalPrice: Int,
        storeName: String,
        cart: CartStore,
        paymentRepository: PaymentRepository = MockPaymentRepository()
    ) {
        self.paymentMethod = paymentMethod
        self.totalPrice = totalPrice
        self.storeName = storeName
        self.cart = cart
        self.paymentRepository = paymentRepository
    }

    func submit() async {
        let previousFailureCount = cart.paymentFailureCount
        let result = (try? await paymentRepository.submitPayment(
            method: paymentMethod,
            totalPrice: totalPrice,
            previousFailureCount: previousFailureCount
        )) ?? .failure

        switch result {
        case .success:
            let pickupNumber = LocalStore.shared.nextPickupNumber()
            let now = Date()
            let order = Order(
                pickupNumber: pickupNumber,
                storeName: storeName,
                status: .confirming,
                items: cart.items.map { OrderItem(name: $0.menuItemName, quantity: $0.quantity, optionsSummary: $0.optionsSummary) },
                subtotalPrice: totalPrice,
                paymentMethod: paymentMethod,
                paidAt: now,
                confirmedAt: now
            )
            LocalStore.shared.addOrder(order)
            cart.clearAfterSuccessfulPayment()
            completedOrderPickupNumber = pickupNumber
        case .failure:
            cart.recordPaymentFailure()
        case .expired:
            break
        }
        outcome = result
    }
}
