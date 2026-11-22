import Foundation

enum PasswordResetRoute: Hashable {
    case emailInput
    case verificationCode
    case newPassword
    case completion
}
