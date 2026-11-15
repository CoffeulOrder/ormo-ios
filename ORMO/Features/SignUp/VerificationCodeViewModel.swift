import Foundation

@Observable
final class VerificationCodeViewModel {
    static let codeLength = 6
    // 인증코드 유효 시간: spec에 정확한 값이 없어 3분으로 둔 placeholder
    private static let totalSeconds = 3 * 60
    private static let maxWrongAttempts = 5

    var code: String = ""
    var remainingSeconds: Int = VerificationCodeViewModel.totalSeconds
    var isExpired: Bool { remainingSeconds <= 0 }
    var shakeTrigger: Int = 0

    var remainingTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var wrongAttemptCount = 0
    private let repository: VerificationCodeRepository
    private var countdownTask: Task<Void, Never>?

    init(repository: VerificationCodeRepository = MockVerificationCodeRepository()) {
        self.repository = repository
        startCountdown()
    }

    func codeChanged(to newValue: String) {
        let filtered = String(newValue.filter(\.isNumber).prefix(Self.codeLength))
        code = filtered
        if filtered.count == Self.codeLength {
            verify()
        }
    }

    func resendTapped() {
        wrongAttemptCount = 0
        code = ""
        remainingSeconds = Self.totalSeconds
        startCountdown()
        // TODO: 인증코드 재발송 API 연동
    }

    func mailNotReceivedTapped() {
        // TODO: 재발송 안내 (화면/시트 미정)
    }

    private func verify() {
        guard !isExpired else { return }

        Task {
            let isValid = await repository.verify(code: code)
            if isValid {
                countdownTask?.cancel()
                // TODO: 0.2.3 이름 입력으로 자동 이동
            } else {
                shakeTrigger += 1
                code = ""
                wrongAttemptCount += 1
                if wrongAttemptCount >= Self.maxWrongAttempts {
                    invalidateCode()
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

    private func invalidateCode() {
        countdownTask?.cancel()
        remainingSeconds = 0
        code = ""
    }
}
