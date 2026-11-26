import Foundation

struct RemotePasswordResetRepository: PasswordResetRepository {
    private struct ResetPasswordBody: Encodable {
        let verificationToken: String
        let newPassword: String
    }

    func resetPassword(verificationToken: String, newPassword: String) async throws {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/members/password-reset",
            body: ResetPasswordBody(verificationToken: verificationToken, newPassword: newPassword),
            requiresAuth: false
        )
        try await APIClient.shared.send(endpoint)
    }
}
