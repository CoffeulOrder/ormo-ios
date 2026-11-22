import Foundation

@Observable
final class SignUpEmailViewModel {
    var emailLocalPart: String = ""

    var schoolEmailDomains: [String] = []
    var selectedSchoolEmailDomain: String = ""
    var isSchoolEmailDomainSheetVisible = false
    var hasMultipleSchoolEmailDomains: Bool { schoolEmailDomains.count > 1 }

    var isLoading = false
    var isAlreadyRegistered = false
    var isDailyLimitExceeded = false

    // 아이디에 공백·한글·특수문자가 있으면 형식 오류 (0.1.1 로그인과 같은 규칙)
    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._%+-")

    var hasValidFormat: Bool {
        !emailLocalPart.isEmpty && emailLocalPart.unicodeScalars.allSatisfy { Self.allowedCharacters.contains($0) }
    }
    var hasFormatError: Bool { !emailLocalPart.isEmpty && !hasValidFormat }

    var fieldErrorMessage: String? {
        if hasFormatError { return "이메일 형식을 확인해주세요" }
        if isAlreadyRegistered { return "이미 가입된 이메일이에요" }
        if isDailyLimitExceeded { return "인증 코드 요청 횟수를 초과했어요" }
        return nil
    }

    var isSubmitEnabled: Bool { hasValidFormat && !isLoading }
    var fullEmail: String { "\(emailLocalPart)@\(selectedSchoolEmailDomain)" }

    private let schoolEmailDomainRepository: SchoolEmailDomainRepository
    private let signUpRepository: SignUpRepository

    init(
        schoolEmailDomainRepository: SchoolEmailDomainRepository = MockSchoolEmailDomainRepository(),
        signUpRepository: SignUpRepository = MockSignUpRepository()
    ) {
        self.schoolEmailDomainRepository = schoolEmailDomainRepository
        self.signUpRepository = signUpRepository
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

    func emailChanged() {
        isAlreadyRegistered = false
        isDailyLimitExceeded = false
    }

    @discardableResult
    func requestVerificationCode() async -> Bool {
        guard isSubmitEnabled else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            try await signUpRepository.requestVerificationCode(email: fullEmail)
            return true
        } catch let failure as SignUpVerificationRequestFailure {
            isAlreadyRegistered = failure.isEmailAlreadyRegistered
            isDailyLimitExceeded = failure.isDailyLimitExceeded
            return false
        } catch {
            return false
        }
    }
}
