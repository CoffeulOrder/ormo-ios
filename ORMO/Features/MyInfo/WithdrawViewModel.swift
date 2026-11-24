import Foundation

@Observable
final class WithdrawViewModel {
    var password: String = ""
    var isPasswordVisible = false
    var isSubmitting = false
    var isPasswordInvalid = false

    var isFormValid: Bool { !password.isEmpty && !isSubmitting }

    func withdrawTapped() async -> Bool {
        guard isFormValid else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(for: .seconds(0.3))

        guard let account = LocalStore.shared.currentAccount, account.password == password else {
            isPasswordInvalid = true
            return false
        }

        LocalStore.shared.deleteAccount(email: account.email)
        return true
    }
}
