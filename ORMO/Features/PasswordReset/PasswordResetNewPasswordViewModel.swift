import Foundation

@Observable
final class PasswordResetNewPasswordViewModel {
    enum Step {
        case password
        case passwordConfirmation
    }

    static let passwordMinLength = 8

    var step: Step = .password

    let email: String
    var password: String = "" {
        didSet { isSameAsCurrentPassword = false }
    }
    var passwordConfirmation: String = ""
    var isPasswordVisible = false
    var isPasswordConfirmationVisible = false
    var isSameAsCurrentPassword = false
    var isSubmitting = false
    var isCompleted = false

    private let passwordResetRepository: PasswordResetRepository

    init(email: String, passwordResetRepository: PasswordResetRepository = AppContainer.shared.passwordResetRepository) {
        self.email = email
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
        case .password: isPasswordRulesSatisfied && !isSameAsCurrentPassword && !isSubmitting
        case .passwordConfirmation: isPasswordConfirmationValid && !isSubmitting
        }
    }

    // 지금 쓰는 비밀번호와 같은지는 서버만 알 수 있어서, 1단계에서 확인을 누르는 시점에 비동기로 확인한다.
    func confirmPasswordTapped() async {
        guard isPasswordRulesSatisfied, !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await passwordResetRepository.validateNewPassword(email: email, newPassword: password)
            isSameAsCurrentPassword = false
            step = .passwordConfirmation
        } catch let failure as PasswordResetFailure where failure.isSameAsCurrentPassword {
            isSameAsCurrentPassword = true
        } catch {
            // 그 외 오류는 현재 디자인에 정의되어 있지 않아 별도 처리하지 않는다.
        }
    }

    func submitTapped() async {
        guard isPasswordConfirmationValid, !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await passwordResetRepository.resetPassword(email: email, newPassword: password)
            isCompleted = true
        } catch {
            // 그 외 오류는 현재 디자인에 정의되어 있지 않아 별도 처리하지 않는다.
        }
    }
}
