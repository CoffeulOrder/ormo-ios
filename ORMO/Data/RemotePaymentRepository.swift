import Foundation

// 개발용 가짜 결제 확정(dev 전용 API)만 쓴다 — 이 호출 하나로 PENDING_PAYMENT → REQUESTED
// 전환과 픽업번호 할당까지 끝난다(사전에 다른 결제 API를 부를 필요 없음). 실제 PortOne 연동은
// 이 구현을 교체해서 붙인다.
struct RemotePaymentRepository: PaymentRepository {
    private struct ConfirmBody: Encodable {
        let pgOrderId: String
    }

    func confirmPayment(
        orderId: Int,
        pgOrderId: String,
        method: PaymentMethod,
        totalPrice: Int,
        previousFailureCount: Int
    ) async throws -> PaymentOutcome {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/dev/orders/\(orderId)/confirm-payment",
            body: ConfirmBody(pgOrderId: pgOrderId)
        )

        do {
            try await APIClient.shared.send(endpoint)
            return .success
        } catch let error as APIError {
            if error.serverCode == "OD009" { return .expired }
            return .failure
        }
    }
}
