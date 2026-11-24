import Foundation

struct MockPasswordResetRepository: PasswordResetRepository {
    func validateNewPassword(email: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.4))

        if LocalStore.shared.account(for: email)?.password == newPassword {
            throw PasswordResetFailure(isSameAsCurrentPassword: true)
        }
    }

    func resetPassword(email: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.6))
        LocalStore.shared.updatePassword(email: email, newPassword: newPassword)
    }
}
