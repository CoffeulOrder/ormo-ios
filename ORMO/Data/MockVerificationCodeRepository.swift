import Foundation

// 테스트 인증코드: 123456
struct MockVerificationCodeRepository: VerificationCodeRepository {
    func requestCode(email: String, purpose: VerificationPurpose) async throws {
        try? await Task.sleep(for: .seconds(0.4))
    }

    // Mock에는 서버가 없어 토큰 자체에 이메일을 실어 보낸다 — 가입·재설정을 완료하는 Mock
    // Repository들이 거기서 이메일을 다시 꺼내 쓴다(MockSignUpRepository.completeSignUp 참고).
    func verify(email: String, purpose: VerificationPurpose, code: String) async throws -> String {
        guard code == "123456" else {
            throw VerificationCodeFailure(isInvalid: true)
        }
        return Self.encodeToken(email: email)
    }

    static func encodeToken(email: String) -> String { "mock-token:\(email)" }

    static func email(fromToken token: String) -> String {
        String(token.dropFirst("mock-token:".count))
    }
}
