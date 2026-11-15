import Foundation

// 테스트 인증코드: 123456
struct MockVerificationCodeRepository: VerificationCodeRepository {
    func verify(code: String) async -> Bool {
        code == "123456"
    }
}
