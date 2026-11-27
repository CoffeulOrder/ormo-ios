import Foundation

struct SignUpVerificationRequestFailure: Error {
    let isEmailAlreadyRegistered: Bool
    let isDailyLimitExceeded: Bool

    init(isEmailAlreadyRegistered: Bool = false, isDailyLimitExceeded: Bool = false) {
        self.isEmailAlreadyRegistered = isEmailAlreadyRegistered
        self.isDailyLimitExceeded = isDailyLimitExceeded
    }
}

// verificationToken이 만료되었거나(30분) 이미 다른 요청에 쓰여 폐기된 경우(EV008). 이 경우
// 이메일 인증부터 다시 받아야 한다.
struct SignUpCompletionFailure: Error {
    let requiresReverification: Bool

    init(requiresReverification: Bool = false) {
        self.requiresReverification = requiresReverification
    }
}

protocol SignUpRepository {
    func requestVerificationCode(email: String) async throws
    func completeSignUp(verificationToken: String, name: String, password: String) async throws
}
