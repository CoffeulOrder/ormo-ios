import Foundation

@Observable
final class LoginViewModel {
    var selectedSchoolEmail: String?
    var password: String = ""

    func selectSchoolEmailTapped() {
        // TODO: 0.1.4 학교 메일 주소 선택 화면으로 이동
    }

    func loginTapped() {
        // TODO: AuthRepository 연동
    }

    func forgotPasswordOrSignUpTapped() {
        // TODO: 비밀번호 재설정 · 회원가입 플로우 연결
    }
}
