import Foundation

@Observable
final class ChangePasswordViewModel {
    static let passwordMinLength = 8

    var currentPassword: String = ""
    var isCurrentPasswordVisible = false
    var isCurrentPasswordInvalid = false
    var password: String = "" {
        didSet { isSameAsCurrentPassword = false }
    }
    var passwordConfirmation: String = ""
    var isPasswordVisible = false
    var isPasswordConfirmationVisible = false
    var isSameAsCurrentPassword = false
    var isSubmitting = false
    var isCompleted = false

    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = AppContainer.shared.userProfileRepository) {
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
        !currentPassword.isEmpty && isPasswordRulesSatisfied && isPasswordConfirmationValid && !isSubmitting
    }

    func currentPasswordChanged() {
        isCurrentPasswordInvalid = false
    }

    func submitTapped() async {
        guard isFormValid else { return }

        // 새 비밀번호가 지금 입력한 현재 비밀번호와 같은지는 클라이언트에서 바로 비교할 수 있다
        // (비밀번호 재설정과 달리 사용자가 현재 비밀번호를 직접 입력하기 때문).
        guard password != currentPassword else {
            isSameAsCurrentPassword = true
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.changePassword(currentPassword: currentPassword, newPassword: password)
            isCompleted = true
        } catch let failure as ChangePasswordFailure where failure.isCurrentPasswordInvalid {
            isCurrentPasswordInvalid = true
        } catch {
            // 그 외 오류는 현재 디자인에 정의되어 있지 않아 별도 처리하지 않는다.
        }
    }
}
