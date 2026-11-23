import Foundation

@Observable
final class ChangePasswordViewModel {
    static let passwordMinLength = 8

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

    private let repository: PasswordResetRepository

    init(email: String, repository: PasswordResetRepository = MockPasswordResetRepository()) {
        self.email = email
        self.repository = repository
    }

    var hasMinLength: Bool { password.count >= Self.passwordMinLength }
    var hasLetterAndDigit: Bool {
        password.contains { $0.isLetter } && password.contains { $0.isNumber }
    }
    var isPasswordRulesSatisfied: Bool { hasMinLength && hasLetterAndDigit }

    var isPasswordMismatched: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation != password
    }
    var isPasswordConfirmationValid: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation == password
    }

    var isFormValid: Bool {
        isPasswordRulesSatisfied && !isSameAsCurrentPassword && isPasswordConfirmationValid && !isSubmitting
    }

    func submitTapped() async {
        guard isPasswordRulesSatisfied, isPasswordConfirmationValid, !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.validateNewPassword(email: email, newPassword: password)
            try await repository.resetPassword(email: email, newPassword: password)
            isCompleted = true
        } catch let failure as PasswordResetFailure where failure.isSameAsCurrentPassword {
            isSameAsCurrentPassword = true
        } catch {
            // 그 외 오류는 현재 디자인에 정의되어 있지 않아 별도 처리하지 않는다.
        }
    }
}
