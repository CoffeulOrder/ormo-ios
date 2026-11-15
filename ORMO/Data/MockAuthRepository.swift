import Foundation

// 테스트 계정: ormo@eulji.ac.kr / ormo1234
struct MockAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws {
        let isEmailInvalid = email.lowercased() != "ormo@eulji.ac.kr"
        let isPasswordInvalid = password != "ormo1234"

        guard !isEmailInvalid, !isPasswordInvalid else {
            throw LoginFailure(isEmailInvalid: isEmailInvalid, isPasswordInvalid: isPasswordInvalid)
        }
    }
}
