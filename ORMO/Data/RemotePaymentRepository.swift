import Foundation

// PaymentCheckoutView에서 실제 PortOne 결제창(PaymentWebView)으로 결제를 끝낸 뒤, 그 결과를
// 서버에 승인받는 단계만 맡는다. 결제창 자체를 띄우는 건 이 레포지토리의 책임이 아니다.
struct RemotePaymentRepository: PaymentRepository {
    private struct ConfirmBody: Encodable {
        let orderId: Int
        let paymentId: String
    }

    func confirmPayment(
        orderId: Int,
        paymentId: String,
        method: PaymentMethod,
        totalPrice: Int,
        previousFailureCount: Int
    ) async throws -> PaymentOutcome {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/payments/confirm",
            body: ConfirmBody(orderId: orderId, paymentId: paymentId)
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
