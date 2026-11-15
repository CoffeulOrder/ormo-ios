import Foundation

@Observable
final class LoginViewModel {
    let schoolEmailDomain = "eulji.ac.kr"

    var emailLocalPart: String = ""
    var password: String = ""

    var emailErrorMessage: String?
    var passwordErrorMessage: String?
    var emailShakeTrigger: Int = 0
    var passwordShakeTrigger: Int = 0

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = MockAuthRepository()) {
        self.authRepository = authRepository
    }

    func selectSchoolEmailTapped() {
        // TODO: 0.1.4 학교 메일 주소 선택 화면으로 이동
    }

    func loginTapped() {
        Task {
            do {
                try await authRepository.login(
                    email: "\(emailLocalPart)@\(schoolEmailDomain)",
                    password: password
                )
                emailErrorMessage = nil
                passwordErrorMessage = nil
                // TODO: 1.1.1 매장 선택으로 이동
            } catch let failure as LoginFailure {
                if failure.isEmailInvalid {
                    emailErrorMessage = "이메일을 다시 확인해 주세요"
                    emailShakeTrigger += 1
                } else {
                    emailErrorMessage = nil
                }

                if failure.isPasswordInvalid {
                    passwordErrorMessage = "비밀번호를 다시 확인해 주세요"
                    passwordShakeTrigger += 1
                } else {
                    passwordErrorMessage = nil
                }
            }
        }
    }

    func forgotPasswordOrSignUpTapped() {
        // TODO: 비밀번호 재설정 · 회원가입 플로우 연결
    }
}
