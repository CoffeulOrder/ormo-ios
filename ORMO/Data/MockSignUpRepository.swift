import Foundation

// 이미 가입된 이메일 테스트: taken@eulji.ac.kr
// 오늘 발송 한도 초과 테스트: limited@eulji.ac.kr
struct MockSignUpRepository: SignUpRepository {
    func requestVerificationCode(email: String) async throws {
        try? await Task.sleep(for: .seconds(0.6)) // 로딩 상태를 보여주기 위한 지연

        let normalizedEmail = email.lowercased()

        if normalizedEmail == "taken@eulji.ac.kr" {
            throw SignUpVerificationRequestFailure(isEmailAlreadyRegistered: true)
        }
        if normalizedEmail == "limited@eulji.ac.kr" {
            throw SignUpVerificationRequestFailure(isDailyLimitExceeded: true)
        }
    }
}
