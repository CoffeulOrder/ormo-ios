import Foundation

// 테스트 계정: ormo@eulji.ac.kr / ormo1234
// 이용 제한 계정 테스트: restricted@eulji.ac.kr (비밀번호 무관)
struct MockAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws {
        let normalizedEmail = email.lowercased()

        if normalizedEmail == "restricted@eulji.ac.kr" {
            throw LoginFailure(isAccountRestricted: true)
        }

        let isEmailInvalid = normalizedEmail != "ormo@eulji.ac.kr"
        let isPasswordInvalid = password != "ormo1234"

        guard !isEmailInvalid, !isPasswordInvalid else {
            throw LoginFailure(isEmailInvalid: isEmailInvalid, isPasswordInvalid: isPasswordInvalid)
        }
    }
}
