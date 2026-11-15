import Foundation

@Observable
final class LoginViewModel {
    private static let maxFailedAttempts = 5
    private static let lockoutDurationSeconds = 15 * 60

    let schoolEmailDomain = "eulji.ac.kr"

    var emailLocalPart: String = ""
    var password: String = ""

    var emailErrorMessage: String?
    var passwordErrorMessage: String?
    var emailShakeTrigger: Int = 0
    var passwordShakeTrigger: Int = 0

    var lockoutRemainingSeconds: Int = 0
    var isLockedOut: Bool { lockoutRemainingSeconds > 0 }
    var isSnackbarVisible = false

    var lockoutCountdownText: String {
        let minutes = lockoutRemainingSeconds / 60
        let seconds = lockoutRemainingSeconds % 60
        return String(format: "%d:%02d 후 로그인", minutes, seconds)
    }

    private var failedAttemptCount = 0
    private let authRepository: AuthRepository
    private var countdownTask: Task<Void, Never>?
    private var snackbarTask: Task<Void, Never>?

    init(authRepository: AuthRepository = MockAuthRepository()) {
        self.authRepository = authRepository
    }

    func selectSchoolEmailTapped() {
        // TODO: 0.1.4 학교 메일 주소 선택 화면으로 이동
    }

    func loginTapped() {
        guard !isLockedOut else { return }

        Task {
            do {
                try await authRepository.login(
                    email: "\(emailLocalPart)@\(schoolEmailDomain)",
                    password: password
                )
                emailErrorMessage = nil
                passwordErrorMessage = nil
                failedAttemptCount = 0
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

                failedAttemptCount += 1
                if failedAttemptCount >= Self.maxFailedAttempts {
                    startLockout()
                }
            }
        }
    }

    func forgotPasswordOrSignUpTapped() {
        // TODO: 재설정하기 → 0.3.1(재설정 시 잠금 즉시 해제), 회원가입 → 0.2.1
    }

    private func startLockout() {
        lockoutRemainingSeconds = Self.lockoutDurationSeconds - 1
        showSnackbar()

        countdownTask?.cancel()
        countdownTask = Task {
            while lockoutRemainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                lockoutRemainingSeconds -= 1
            }
            failedAttemptCount = 0
        }
    }

    private func showSnackbar() {
        isSnackbarVisible = true
        snackbarTask?.cancel()
        snackbarTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isSnackbarVisible = false
        }
    }
}
