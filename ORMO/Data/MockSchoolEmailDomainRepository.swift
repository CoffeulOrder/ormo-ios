import Foundation

struct MockSchoolEmailDomainRepository: SchoolEmailDomainRepository {
    func fetchDomains() async throws -> [String] {
        ["eulji.ac.kr", "g.eulji.ac.kr"]
    }
}
