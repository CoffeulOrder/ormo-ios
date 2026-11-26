import Foundation

@Observable
final class PasswordResetEmailViewModel {
    var emailLocalPart: String = ""
    var isEmailValid: Bool { !emailLocalPart.isEmpty }

    var schoolEmailDomains: [String] = []
    var selectedSchoolEmailDomain: String = ""
    var isSchoolEmailDomainSheetVisible = false
    var hasMultipleSchoolEmailDomains: Bool { schoolEmailDomains.count > 1 }

    private let schoolEmailDomainRepository: SchoolEmailDomainRepository
    private let verificationCodeRepository: VerificationCodeRepository

    init(
        schoolEmailDomainRepository: SchoolEmailDomainRepository = AppContainer.shared.schoolEmailDomainRepository,
        verificationCodeRepository: VerificationCodeRepository = AppContainer.shared.verificationCodeRepository
    ) {
        self.schoolEmailDomainRepository = schoolEmailDomainRepository
        self.verificationCodeRepository = verificationCodeRepository
    }

    // 가입 여부와 무관하게 같은 안내를 보여줘야 해서(계정 노출 방지), 실패해도 화면에 따로
    // 알리지 않고 그대로 다음 화면으로 넘어간다.
    func requestCode(email: String) async {
        try? await verificationCodeRepository.requestCode(email: email, purpose: .passwordReset)
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
}
