import Foundation

// 결제수단별 트리거: 신용·체크카드 → 처음엔 실패, 재시도하면 성공. 네이버페이 → 결제 가능 시간 만료.
// 토스페이·카카오페이(기본값) → 바로 결제 성공.
struct MockPaymentRepository: PaymentRepository {
    func submitPayment(method: PaymentMethod, totalPrice: Int, previousFailureCount: Int) async throws -> PaymentOutcome {
        try? await Task.sleep(for: .seconds(2))

        switch method {
        case .card:
            return previousFailureCount > 0 ? .success : .failure
        case .naverPay:
            return .expired
        case .tossPay, .kakaoPay:
            return .success
        }
    }
}
