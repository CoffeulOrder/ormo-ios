import Foundation

protocol SchoolEmailDomainRepository {
    func fetchDomains() async throws -> [String]
}
