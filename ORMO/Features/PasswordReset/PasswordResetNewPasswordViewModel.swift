import Foundation

@Observable
final class PasswordResetNewPasswordViewModel {
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

    // TODO: 지금 쓰는 비밀번호와 같으면 "지금 쓰는 비밀번호와 달라야 해요" 오류를 보여줘야 하는데,
    // 이 값은 서버만 알 수 있어서(현재 비밀번호 해시) Remote Repository 연동 시 추가해야 한다.

    var isValid: Bool {
        isPasswordValid && !passwordConfirmation.isEmpty && passwordConfirmation == password
    }
}
