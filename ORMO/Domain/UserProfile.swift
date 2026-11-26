import Foundation

struct UserProfile {
    let name: String
    let email: String
    let schoolName: String
}

struct ChangePasswordFailure: Error {
    let isCurrentPasswordInvalid: Bool

    init(isCurrentPasswordInvalid: Bool = false) {
        self.isCurrentPasswordInvalid = isCurrentPasswordInvalid
    }
}

struct WithdrawFailure: Error {
    let isPasswordInvalid: Bool
    let hasOngoingOrders: Bool

    init(isPasswordInvalid: Bool = false, hasOngoingOrders: Bool = false) {
        self.isPasswordInvalid = isPasswordInvalid
        self.hasOngoingOrders = hasOngoingOrders
    }
}

protocol UserProfileRepository {
    func fetchProfile() async throws -> UserProfile
    // 로그인한 상태에서 비밀번호를 바꿀 때. 비밀번호 재설정(PasswordResetRepository)과 달리
    // 현재 비밀번호를 직접 입력받아 확인한다.
    func changePassword(currentPassword: String, newPassword: String) async throws
    func withdraw(password: String) async throws
}
