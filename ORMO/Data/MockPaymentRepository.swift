import Foundation

// 실제 PG사 연동 전까지는 결제수단과 상관없이 항상 성공시켜, 결제 이후 전체 흐름(주문 완료·추적·내역)을
// 실제로 테스트할 수 있게 한다. 실패·만료 화면(PaymentFailureView·PaymentExpiredView) 자체는 그대로
// 남아있고 Preview로 확인할 수 있다.
struct MockPaymentRepository: PaymentRepository {
    func confirmPayment(
        orderId: Int,
        paymentId: String,
        method: PaymentMethod,
        totalPrice: Int,
        previousFailureCount: Int
    ) async throws -> PaymentOutcome {
        try? await Task.sleep(for: .seconds(1.2))
        return .success
    }
}
