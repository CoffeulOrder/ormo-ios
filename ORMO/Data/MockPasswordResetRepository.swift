import Foundation

// 지금 쓰는 비밀번호와 같음 테스트: 새 비밀번호를 ormo1234로 입력 (ormo@eulji.ac.kr 테스트 계정의 현재 비밀번호)
struct MockPasswordResetRepository: PasswordResetRepository {
    func validateNewPassword(email: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.4))

        if newPassword == "ormo1234" {
            throw PasswordResetFailure(isSameAsCurrentPassword: true)
        }
    }

    func resetPassword(email: String, newPassword: String) async throws {
        try? await Task.sleep(for: .seconds(0.6))
    }
}
