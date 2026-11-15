import Foundation

struct LoginFailure: Error {
    let isEmailInvalid: Bool
    let isPasswordInvalid: Bool
}

protocol AuthRepository {
    func login(email: String, password: String) async throws
}
