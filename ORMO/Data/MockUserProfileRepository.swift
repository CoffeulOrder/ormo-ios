import Foundation

struct MockUserProfileRepository: UserProfileRepository {
    func fetchProfile() async throws -> UserProfile {
        UserProfile(name: "가을", email: "ormo@eulji.ac.kr", schoolName: "을지대학교")
    }
}
