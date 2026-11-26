import Foundation

struct ProfileFetchError: Error {}

struct MockUserProfileRepository: UserProfileRepository {
    func fetchProfile() async throws -> UserProfile {
        guard let account = LocalStore.shared.currentAccount else {
            throw ProfileFetchError()
        }
        return UserProfile(name: account.name, email: account.email, schoolName: account.schoolName)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.4))
        guard let account = LocalStore.shared.currentAccount, account.password == currentPassword else {
            throw ChangePasswordFailure(isCurrentPasswordInvalid: true)
        }
        LocalStore.shared.updatePassword(email: account.email, newPassword: newPassword)
    }

    func withdraw(password: String) async throws {
        try? await Task.sleep(for: .seconds(0.3))
        guard let account = LocalStore.shared.currentAccount, account.password == password else {
            throw WithdrawFailure(isPasswordInvalid: true)
        }
        LocalStore.shared.deleteAccount(email: account.email)
    }
}
