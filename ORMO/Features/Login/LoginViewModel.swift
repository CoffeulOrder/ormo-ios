import Foundation
import SwiftUI

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
    var isLoginSucceeded = false
    var isSnackbarVisible = false
    var snackbarMessage = "비밀번호를 5회 틀렸어요"
    var snackbarIcon: ImageResource = .alertIconLarge
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
                // 1.1.1 매장 선택 화면이 아직 없어 바로 메뉴 홈으로 이동한다.
                isLoginSucceeded = true
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
        isPasswordResetRequested = true
    }

    // 0.3.3 재설정 완료 화면에서 "로그인하기"를 탭하면 호출된다. 잠금을 풀고 이메일을 미리 채운 뒤 토스트를 보여준다.
    func passwordResetCompleted(email: String) {
        let parts = email.split(separator: "@", maxSplits: 1)
        emailLocalPart = parts.first.map(String.init) ?? ""
        if parts.count > 1 {
            selectedSchoolEmailDomain = String(parts[1])
        }
        password = ""

        failedAttemptCount = 0
        lockoutRemainingSeconds = 0
        countdownTask?.cancel()

        snackbarMessage = "비밀번호를 변경했어요"
        snackbarIcon = .toastSuccessIcon
        showSnackbar()
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
        snackbarMessage = "비밀번호를 5회 틀렸어요"
        snackbarIcon = .alertIconLarge
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
