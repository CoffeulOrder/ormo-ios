import Foundation

struct RemoteSignUpRepository: SignUpRepository {
    private struct RequestCodeBody: Encodable {
        let email: String
        let purpose: String
    }

    private struct AgreementItemBody: Encodable {
        let type: String
        let version: String
        let agreed: Bool
    }

    private struct CompleteSignUpBody: Encodable {
        let verificationToken: String
        let name: String
        let password: String
        let agreements: [AgreementItemBody]
    }

    private struct CompleteSignUpResponseData: Decodable {
        let accessToken: String
        let refreshToken: String
    }

    // 정식 법무 문구·버전 관리가 아직 없어(TermsDocument 참고) 고정값을 쓴다. 실제 약관 버전이
    // 생기면 TermsDocument 쪽에서 버전을 받아와야 한다.
    private static let termsVersion = "1.0"

    func requestVerificationCode(email: String) async throws {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/verifications/email",
            body: RequestCodeBody(email: email, purpose: VerificationPurpose.signUp.rawValue),
            requiresAuth: false
        )

        do {
            try await APIClient.shared.send(endpoint)
        } catch let error as APIError {
            switch error.serverCode {
            case "EV006", "U001":
                throw SignUpVerificationRequestFailure(isEmailAlreadyRegistered: true)
            case "EV003":
                throw SignUpVerificationRequestFailure(isDailyLimitExceeded: true)
            default:
                throw error
            }
        }
    }

    func completeSignUp(verificationToken: String, name: String, password: String) async throws {
        let body = CompleteSignUpBody(
            verificationToken: verificationToken,
            name: name,
            password: password,
            agreements: [
                AgreementItemBody(type: "SERVICE", version: Self.termsVersion, agreed: true),
                AgreementItemBody(type: "PRIVACY", version: Self.termsVersion, agreed: true),
            ]
        )
        let endpoint = Endpoint(method: .post, path: "/api/v1/members", body: body, requiresAuth: false)
        let data: CompleteSignUpResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: CompleteSignUpResponseData.self)
        TokenStore.shared.save(accessToken: data.accessToken, refreshToken: data.refreshToken)
    }
}
