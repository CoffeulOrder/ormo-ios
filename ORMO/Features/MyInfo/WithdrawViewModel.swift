import Foundation

@Observable
final class WithdrawViewModel {
    var password: String = ""
    var isPasswordVisible = false
    var isSubmitting = false

    var isFormValid: Bool { !password.isEmpty && !isSubmitting }

    func withdrawTapped() async -> Bool {
        guard isFormValid else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(for: .seconds(0.3))
        return true
    }
}
