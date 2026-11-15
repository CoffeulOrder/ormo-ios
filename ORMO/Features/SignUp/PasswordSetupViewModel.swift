import Foundation

@Observable
final class PasswordSetupViewModel {
    static let minLength = 8

    var password: String = ""
    var passwordConfirmation: String = ""
    var isPasswordVisible = false
    var isPasswordConfirmationVisible = false

    var hasMinLength: Bool { password.count >= Self.minLength }
    var hasLetterAndDigit: Bool {
        password.contains { $0.isLetter } && password.contains { $0.isNumber }
    }
    var isPasswordValid: Bool { hasMinLength && hasLetterAndDigit }

    // 확인 칸이 다르면: 비밀번호가 서로 달라요
    var isMismatched: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation != password
    }

    var isValid: Bool {
        isPasswordValid && !passwordConfirmation.isEmpty && passwordConfirmation == password
    }
}
