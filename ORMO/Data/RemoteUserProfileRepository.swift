import Foundation

struct RemoteUserProfileRepository: UserProfileRepository {
    private struct SchoolData: Decodable {
        let name: String
    }

    private struct ProfileResponseData: Decodable {
        let name: String
        let email: String
        let school: SchoolData
    }

    private struct ChangePasswordBody: Encodable {
        let currentPassword: String
        let newPassword: String
    }

    private struct WithdrawBody: Encodable {
        let password: String
    }

    func fetchProfile() async throws -> UserProfile {
        let endpoint = Endpoint(method: .get, path: "/api/v1/members/me")
        let data: ProfileResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: ProfileResponseData.self)
        return UserProfile(name: data.name, email: data.email, schoolName: data.school.name)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let endpoint = Endpoint(
            method: .patch,
            path: "/api/v1/members/me/password",
            body: ChangePasswordBody(currentPassword: currentPassword, newPassword: newPassword)
        )

        do {
            try await APIClient.shared.send(endpoint)
        } catch let error as APIError {
            if error.serverCode == "U004" {
                throw ChangePasswordFailure(isCurrentPasswordInvalid: true)
            }
            throw error
        }
    }

    func withdraw(password: String) async throws {
        let endpoint = Endpoint(method: .delete, path: "/api/v1/members/me", body: WithdrawBody(password: password))

        do {
            try await APIClient.shared.send(endpoint)
            TokenStore.shared.clear()
        } catch let error as APIError {
            switch error.serverCode {
            case "U004":
                throw WithdrawFailure(isPasswordInvalid: true)
            case "U005":
                throw WithdrawFailure(hasOngoingOrders: true)
            default:
                throw error
            }
        }
    }
}
