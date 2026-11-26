import Foundation

struct RemoteAuthRepository: AuthRepository {
    private struct LoginRequestBody: Encodable {
        let email: String
        let password: String
    }

    private struct LoginResponseData: Decodable {
        let accessToken: String
        let refreshToken: String
    }

    private struct LogoutRequestBody: Encodable {
        let refreshToken: String
    }

    func login(email: String, password: String) async throws {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/auth/login",
            body: LoginRequestBody(email: email, password: password),
            requiresAuth: false
        )

        do {
            let data: LoginResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: LoginResponseData.self)
            TokenStore.shared.save(accessToken: data.accessToken, refreshToken: data.refreshToken)
        } catch let error as APIError {
            // 서버가 이메일·비밀번호 중 무엇이 잘못됐는지 구분해주지 않아(AUTH_001 하나로 묶임),
            // 기존 UI 문구("이메일이나 비밀번호를 다시 확인해 주세요")에 맞춰 둘 다 true로 매핑한다.
            if error.serverCode == "AUTH_001" {
                throw LoginFailure(isEmailInvalid: true, isPasswordInvalid: true)
            }
            throw error
        }
    }

    func logout() async throws {
        defer { TokenStore.shared.clear() }
        guard let refreshToken = TokenStore.shared.refreshToken else { return }
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/auth/logout",
            body: LogoutRequestBody(refreshToken: refreshToken)
        )
        try await APIClient.shared.send(endpoint)
    }
}
