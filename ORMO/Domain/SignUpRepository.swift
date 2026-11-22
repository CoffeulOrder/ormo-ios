import Foundation

struct SignUpVerificationRequestFailure: Error {
    let isEmailAlreadyRegistered: Bool
    let isDailyLimitExceeded: Bool

    init(isEmailAlreadyRegistered: Bool = false, isDailyLimitExceeded: Bool = false) {
        self.isEmailAlreadyRegistered = isEmailAlreadyRegistered
        self.isDailyLimitExceeded = isDailyLimitExceeded
    }
}

protocol SignUpRepository {
    func requestVerificationCode(email: String) async throws
}
