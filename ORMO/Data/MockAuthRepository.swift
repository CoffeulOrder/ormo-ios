import Foundation

// 이용 제한 계정 테스트: restricted@eulji.ac.kr (비밀번호 무관)
// 그 외에는 LocalStore에 실제로 등록된 계정(데모 계정 ormo@eulji.ac.kr / ormo1234 포함)으로 로그인된다.
struct MockAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws {
        let normalizedEmail = email.lowercased()

        if normalizedEmail == "restricted@eulji.ac.kr" {
            throw LoginFailure(isAccountRestricted: true)
        }

        let account = LocalStore.shared.account(for: normalizedEmail)
        let isEmailInvalid = account == nil
        let isPasswordInvalid = account?.password != password

        guard !isEmailInvalid, !isPasswordInvalid, let account else {
            throw LoginFailure(isEmailInvalid: isEmailInvalid, isPasswordInvalid: isPasswordInvalid)
        }

        LocalStore.shared.login(email: account.email)
    }

    func logout() async throws {
        LocalStore.shared.logout()
    }
}
