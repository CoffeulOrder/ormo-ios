import Foundation

// 이미 가입된 이메일 테스트: taken@eulji.ac.kr
// 오늘 발송 한도 초과 테스트: limited@eulji.ac.kr
// 그 외 이메일은 실제로 LocalStore에 등록되어, 이후 로그인·내 정보에서 그대로 쓸 수 있다.
struct MockSignUpRepository: SignUpRepository {
    // 지금은 전교생이 같은 학교 메일을 쓰는 단일 캠퍼스 서비스라 고정값으로 둔다.
    private static let schoolName = "을지대학교"

    func requestVerificationCode(email: String) async throws {
        try? await Task.sleep(for: .seconds(0.6)) // 로딩 상태를 보여주기 위한 지연

        let normalizedEmail = email.lowercased()

        if normalizedEmail == "taken@eulji.ac.kr" {
            throw SignUpVerificationRequestFailure(isEmailAlreadyRegistered: true)
        }
        if normalizedEmail == "limited@eulji.ac.kr" {
            throw SignUpVerificationRequestFailure(isDailyLimitExceeded: true)
        }
        if LocalStore.shared.account(for: normalizedEmail) != nil {
            throw SignUpVerificationRequestFailure(isEmailAlreadyRegistered: true)
        }
    }

    func completeSignUp(verificationToken: String, name: String, password: String) async throws {
        try? await Task.sleep(for: .seconds(0.4))
        let email = MockVerificationCodeRepository.email(fromToken: verificationToken)
        LocalStore.shared.register(email: email, password: password, name: name, schoolName: Self.schoolName)
    }
}
