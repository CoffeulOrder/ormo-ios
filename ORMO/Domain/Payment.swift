import Foundation

enum PaymentOutcome: Hashable {
    case success
    case failure
    case expired
}

protocol PaymentRepository {
    // previousFailureCount: 같은 장바구니로 이 결제수단이 이미 실패한 횟수. 재시도 결과를
    // 달리 보여주는 데 쓴다(예: 카드가 처음엔 실패하지만 재시도하면 성공하는 Mock 시나리오).
    func submitPayment(method: PaymentMethod, totalPrice: Int, previousFailureCount: Int) async throws -> PaymentOutcome
}
