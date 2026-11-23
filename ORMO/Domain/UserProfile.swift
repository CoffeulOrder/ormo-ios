import Foundation

struct UserProfile {
    let name: String
    let email: String
    let schoolName: String
}

protocol UserProfileRepository {
    func fetchProfile() async throws -> UserProfile
}
