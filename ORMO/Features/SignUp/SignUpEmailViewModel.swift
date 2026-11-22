import Foundation

@Observable
final class SignUpEmailViewModel {
    var emailLocalPart: String = ""
    var isEmailValid: Bool { !emailLocalPart.isEmpty }

    var schoolEmailDomains: [String] = []
    var selectedSchoolEmailDomain: String = ""
    var isSchoolEmailDomainSheetVisible = false
    var hasMultipleSchoolEmailDomains: Bool { schoolEmailDomains.count > 1 }

    private let schoolEmailDomainRepository: SchoolEmailDomainRepository

    init(schoolEmailDomainRepository: SchoolEmailDomainRepository = MockSchoolEmailDomainRepository()) {
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
}
