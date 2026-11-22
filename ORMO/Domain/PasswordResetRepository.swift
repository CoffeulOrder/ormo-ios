import Foundation

struct PasswordResetFailure: Error {
    let isSameAsCurrentPassword: Bool

    init(isSameAsCurrentPassword: Bool = false) {
        self.isSameAsCurrentPassword = isSameAsCurrentPassword
    }
}

protocol PasswordResetRepository {
    func validateNewPassword(email: String, newPassword: String) async throws
    func resetPassword(email: String, newPassword: String) async throws
}
