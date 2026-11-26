import Foundation

struct MockPasswordResetRepository: PasswordResetRepository {
    func resetPassword(verificationToken: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.6))
        let email = MockVerificationCodeRepository.email(fromToken: verificationToken)
        LocalStore.shared.updatePassword(email: email, newPassword: newPassword)
    }
}
