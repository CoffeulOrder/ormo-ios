import Foundation

struct LoginFailure: Error {
    let isEmailInvalid: Bool
    let isPasswordInvalid: Bool
    let isAccountRestricted: Bool

    init(isEmailInvalid: Bool = false, isPasswordInvalid: Bool = false, isAccountRestricted: Bool = false) {
        self.isEmailInvalid = isEmailInvalid
        self.isPasswordInvalid = isPasswordInvalid
        self.isAccountRestricted = isAccountRestricted
    }
}

protocol AuthRepository {
    func login(email: String, password: String) async throws
}
