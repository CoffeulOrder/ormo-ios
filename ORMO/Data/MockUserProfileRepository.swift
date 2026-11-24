import Foundation

struct ProfileFetchError: Error {}

struct MockUserProfileRepository: UserProfileRepository {
    func fetchProfile() async throws -> UserProfile {
        guard let account = LocalStore.shared.currentAccount else {
            throw ProfileFetchError()
        }
        return UserProfile(name: account.name, email: account.email, schoolName: account.schoolName)
    }
}
