import Foundation

@Observable
final class LoginViewModel {
    private static let maxFailedAttempts = 5
    private static let lockoutDurationSeconds = 15 * 60

    var emailLocalPart: String = ""
    var password: String = ""

    var schoolEmailDomains: [String] = []
    var selectedSchoolEmailDomain: String = ""
    var isSchoolEmailDomainSheetVisible = false
    var hasMultipleSchoolEmailDomains: Bool { schoolEmailDomains.count > 1 }

    var emailErrorMessage: String?
    var passwordErrorMessage: String?
    var emailShakeTrigger: Int = 0
    var passwordShakeTrigger: Int = 0

    var lockoutRemainingSeconds: Int = 0
    var isLockedOut: Bool { lockoutRemainingSeconds > 0 }
    var isSnackbarVisible = false
    var isRestrictedAccountDialogVisible = false
    var isPasswordResetRequested = false

    var lockoutCountdownText: String {
        let minutes = lockoutRemainingSeconds / 60
        let seconds = lockoutRemainingSeconds % 60
        return String(format: "%d:%02d 후 로그인", minutes, seconds)
    }

    private var failedAttemptCount = 0
    private let authRepository: AuthRepository
    private let schoolEmailDomainRepository: SchoolEmailDomainRepository
    private var countdownTask: Task<Void, Never>?
    private var snackbarTask: Task<Void, Never>?

    init(
        authRepository: AuthRepository = MockAuthRepository(),
        schoolEmailDomainRepository: SchoolEmailDomainRepository = MockSchoolEmailDomainRepository()
    ) {
        self.authRepository = authRepository
        self.schoolEmailDomainRepository = schoolEmailDomainRepository
    }

    func loadSchoolEmailDomainsIfNeeded() async {
        guard schoolEmailDomains.isEmpty else { return }
        guard let domains = try? await schoolEmailDomainRepository.fetchDomains(), !domains.isEmpty else { return }
        schoolEmailDomains = domains
        selectedSchoolEmailDomain = domains[0]
    }

    func selectSchoolEmailTapped() {
        guard hasMultipleSchoolEmailDomains else { return }
        isSchoolEmailDomainSheetVisible = true
    }

    func selectSchoolEmailDomain(_ domain: String) {
        selectedSchoolEmailDomain = domain
        isSchoolEmailDomainSheetVisible = false
    }

    func loginTapped() {
        guard !isLockedOut else { return }

        Task {
            do {
                try await authRepository.login(
                    email: "\(emailLocalPart)@\(selectedSchoolEmailDomain)",
                    password: password
                )
                emailErrorMessage = nil
                passwordErrorMessage = nil
                failedAttemptCount = 0
                // TODO: 1.1.1 매장 선택으로 이동
            } catch let failure as LoginFailure {
                if failure.isAccountRestricted {
                    isRestrictedAccountDialogVisible = true
                    return
                }

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

    func forgotPasswordTapped() {
        // TODO: 재설정 완료(0.3.3) 후 전달받는 콜백으로 잠금 즉시 해제
        isPasswordResetRequested = true
    }

    func dismissRestrictedAccountDialog() {
        isRestrictedAccountDialogVisible = false
    }

    func contactSupportTapped() {
        // TODO: 고객센터 문의 채널 연결 (카카오 채널·메일 중 확인 필요)
        isRestrictedAccountDialogVisible = false
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
