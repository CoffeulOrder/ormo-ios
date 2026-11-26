import Foundation

struct RemoteVerificationCodeRepository: VerificationCodeRepository {
    private struct RequestCodeBody: Encodable {
        let email: String
        let purpose: String
    }

    private struct ConfirmBody: Encodable {
        let email: String
        let purpose: String
        let code: String
    }

    private struct ConfirmResponseData: Decodable {
        let verificationToken: String
    }

    func requestCode(email: String, purpose: VerificationPurpose) async throws {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/verifications/email",
            body: RequestCodeBody(email: email, purpose: purpose.rawValue),
            requiresAuth: false
        )
        try await APIClient.shared.send(endpoint)
    }

    func verify(email: String, purpose: VerificationPurpose, code: String) async throws -> String {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/verifications/email/confirm",
            body: ConfirmBody(email: email, purpose: purpose.rawValue, code: code),
            requiresAuth: false
        )

        do {
            let data: ConfirmResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: ConfirmResponseData.self)
            return data.verificationToken
        } catch let error as APIError {
            switch error.serverCode {
            case "EV004":
                throw VerificationCodeFailure(isInvalid: true)
            case "EV005":
                throw VerificationCodeFailure(isExpired: true)
            default:
                throw error
            }
        }
    }
}
