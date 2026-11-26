import Foundation

@Observable
final class WithdrawViewModel {
    var password: String = ""
    var isPasswordVisible = false
    var isSubmitting = false
    var isPasswordInvalid = false

    var isFormValid: Bool { !password.isEmpty && !isSubmitting }

    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = AppContainer.shared.userProfileRepository) {
        self.repository = repository
    }

    func withdrawTapped() async -> Bool {
        guard isFormValid else { return false }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.withdraw(password: password)
            return true
        } catch let failure as WithdrawFailure where failure.isPasswordInvalid {
            isPasswordInvalid = true
            return false
        } catch {
            return false
        }
    }
}
