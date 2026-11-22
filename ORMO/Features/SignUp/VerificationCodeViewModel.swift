import Foundation

@Observable
final class VerificationCodeViewModel {
    static let codeLength = 6
    // 코드 유효 시간: Figma 목업의 "남은 시간 4:59" 기준 5분
    private static let totalSeconds = 5 * 60
    private static let maxWrongAttempts = 5
    private static let resendCooldownSeconds = 59

    var code: String = ""
    var remainingSeconds: Int = VerificationCodeViewModel.totalSeconds
    var isExpired: Bool { remainingSeconds <= 0 }
    var isInvalid = false
    // 5번 틀려서 그 코드를 더 쓸 수 없는 상태
    var isExhausted = false
    // 만료되었거나 5번 틀려서 입력칸 자체가 꺼진 상태
    var isLocked: Bool { isExpired || isExhausted }
    var shakeTrigger: Int = 0
    var isVerified = false
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

    init(repository: VerificationCodeRepository = MockVerificationCodeRepository()) {
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
        inputGeneration += 1
        remainingSeconds = Self.totalSeconds
        startCountdown()
        startResendCooldown()
        // TODO: 인증코드 재발송 API 연동
    }

    func mailNotReceivedTapped() {
        // TODO: 재발송 안내 (화면/시트 미정)
    }

    private func verify() {
        guard !isLocked else { return }

        Task {
            let isValid = await repository.verify(code: code)
            if isValid {
                countdownTask?.cancel()
                isVerified = true
            } else {
                isInvalid = true
                shakeTrigger += 1
                wrongAttemptCount += 1
                if wrongAttemptCount >= Self.maxWrongAttempts {
                    isExhausted = true
                    countdownTask?.cancel()
                }
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
