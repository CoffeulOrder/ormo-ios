import Foundation

enum VerificationPurpose: String {
    case signUp = "SIGNUP"
    case passwordReset = "PASSWORD_RESET"
}

struct VerificationCodeFailure: Error {
    let isInvalid: Bool
    let isExpired: Bool

    init(isInvalid: Bool = false, isExpired: Bool = false) {
        self.isInvalid = isInvalid
        self.isExpired = isExpired
    }
}

protocol VerificationCodeRepository {
    func requestCode(email: String, purpose: VerificationPurpose) async throws
    // 성공하면 가입·비밀번호 재설정 단계에서 쓸 verificationToken을 돌려준다.
    func verify(email: String, purpose: VerificationPurpose, code: String) async throws -> String
}
