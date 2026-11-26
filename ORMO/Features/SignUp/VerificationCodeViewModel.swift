import Foundation

@Observable
final class VerificationCodeViewModel {
    static let codeLength = 6
    // 코드 유효 시간: Figma 목업의 "남은 시간 4:59" 기준 5분
    private static let totalSeconds = 5 * 60
    private static let maxWrongAttempts = 5
    private static let resendCooldownSeconds = 59

    let email: String
    let purpose: VerificationPurpose

    var code: String = ""
    var remainingSeconds: Int = VerificationCodeViewModel.totalSeconds
    var isExpired = false
    // 5번 틀려서 그 코드를 더 쓸 수 없는 상태
    var isExhausted = false
    // 만료되었거나 5번 틀려서 입력칸 자체가 꺼진 상태
    var isLocked: Bool { isExpired || isExhausted }
    var shakeTrigger: Int = 0
    var isInvalid = false
    var isVerified = false
    // 성공 시 서버가 돌려준 토큰. onVerified로 넘겨주기 전까지 잠깐 들고 있는다.
    private(set) var verificationToken: String?
    // 코드를 외부에서(재발송 등) 강제로 비울 때, 숨겨진 TextField가 iOS 내부 편집 버퍼를
    // 그대로 들고 있어 다음 입력에 이전 값이 섞이는 문제가 있어 뷰 쪽에서 .id()로
    // TextField를 강제로 다시 만들도록 이 값을 올린다.
    var inputGeneration = 0
    var resendCooldownRemainingSeconds = 0
    var isResendCoolingDown: Bool { resendCooldownRemainingSeconds > 0 }

    var remainingTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var resendCooldownText: String {
        "0:\(String(format: "%02d", resendCooldownRemainingSeconds))"
    }

    private var wrongAttemptCount = 0
    private let repository: VerificationCodeRepository
    private var countdownTask: Task<Void, Never>?
    private var resendCooldownTask: Task<Void, Never>?

    init(
        email: String,
        purpose: VerificationPurpose,
        repository: VerificationCodeRepository = AppContainer.shared.verificationCodeRepository
    ) {
        self.email = email
        self.purpose = purpose
        self.repository = repository
        startCountdown()
        startResendCooldown()
    }

    func codeChanged(to newValue: String) {
        guard !isLocked else { return }
        let filtered = String(newValue.filter(\.isNumber).prefix(Self.codeLength))
        if filtered != code {
            isInvalid = false
        }
        code = filtered
        if filtered.count == Self.codeLength {
            verify()
        }
    }

    func resendTapped() {
        wrongAttemptCount = 0
        code = ""
        isInvalid = false
        isExhausted = false
        isExpired = false
        inputGeneration += 1
        remainingSeconds = Self.totalSeconds
        startCountdown()
        startResendCooldown()
        Task { try? await repository.requestCode(email: email, purpose: purpose) }
    }

    func mailNotReceivedTapped() {
        // TODO: 재발송 안내 (화면/시트 미정)
    }

    func consumeVerificationToken() -> String {
        defer { verificationToken = nil }
        return verificationToken ?? ""
    }

    private func verify() {
        guard !isLocked else { return }

        Task {
            do {
                let token = try await repository.verify(email: email, purpose: purpose, code: code)
                countdownTask?.cancel()
                verificationToken = token
                isVerified = true
            } catch let failure as VerificationCodeFailure {
                if failure.isExpired {
                    isExpired = true
                    countdownTask?.cancel()
                    return
                }
                isInvalid = true
                shakeTrigger += 1
                wrongAttemptCount += 1
                if wrongAttemptCount >= Self.maxWrongAttempts {
                    isExhausted = true
                    countdownTask?.cancel()
                }
            } catch {
                isInvalid = true
                shakeTrigger += 1
            }
        }
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1
            }
            isExpired = true
        }
    }

    private func startResendCooldown() {
        resendCooldownTask?.cancel()
        resendCooldownRemainingSeconds = Self.resendCooldownSeconds
        resendCooldownTask = Task {
            while resendCooldownRemainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                resendCooldownRemainingSeconds -= 1
            }
        }
    }
}
