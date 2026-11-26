import Foundation

@Observable
final class PasswordResetNewPasswordViewModel {
    enum Step {
        case password
        case passwordConfirmation
    }

    static let passwordMinLength = 8

    var step: Step = .password

    let verificationToken: String
    var password: String = ""
    var passwordConfirmation: String = ""
    var isPasswordVisible = false
    var isPasswordConfirmationVisible = false
    var isSubmitting = false
    var isCompleted = false

    private let passwordResetRepository: PasswordResetRepository

    init(verificationToken: String, passwordResetRepository: PasswordResetRepository = AppContainer.shared.passwordResetRepository) {
        self.verificationToken = verificationToken
        self.passwordResetRepository = passwordResetRepository
    }

    var hasMinLength: Bool { password.count >= Self.passwordMinLength }
    var hasLetterAndDigit: Bool {
        password.contains { $0.isLetter } && password.contains { $0.isNumber }
    }
    var isPasswordRulesSatisfied: Bool { hasMinLength && hasLetterAndDigit }

    // 확인 칸이 다르면: 비밀번호가 일치하지 않아요
    var isPasswordMismatched: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation != password
    }
    var isPasswordConfirmationValid: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation == password
    }

    var isCurrentStepValid: Bool {
        switch step {
        case .password: isPasswordRulesSatisfied && !isSubmitting
        case .passwordConfirmation: isPasswordConfirmationValid && !isSubmitting
        }
    }

    // 서버에는 "지금 비밀번호와 같은지"를 미리 물어볼 방법이 없어(verificationToken만으로는
    // 현재 비밀번호를 알 수 없음), 형식만 맞으면 바로 다음 단계로 넘어간다.
    func confirmPasswordTapped() {
        guard isPasswordRulesSatisfied else { return }
        step = .passwordConfirmation
    }

    func submitTapped() async {
        guard isPasswordConfirmationValid, !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await passwordResetRepository.resetPassword(verificationToken: verificationToken, newPassword: password)
            isCompleted = true
        } catch {
            // 그 외 오류는 현재 디자인에 정의되어 있지 않아 별도 처리하지 않는다.
        }
    }
}
