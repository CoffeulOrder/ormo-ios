import Foundation

enum StoreOperatingStatus: Hashable {
    case open
    case closed
}

struct OperatingHours: Hashable {
    let weekdays: String
    let saturday: String
    let sundayAndHoliday: String
}

struct SellerInfo: Hashable {
    let businessName: String
    let representative: String
    let registrationNumber: String
    let address: String
    let phoneNumber: String
    let mailOrderNumber: String
}

struct Store: Identifiable, Hashable {
    let id: String
    let name: String
    let status: StoreOperatingStatus
    let address: String
    let distanceText: String
    let walkTimeText: String
    let location: String
    let operatingHours: OperatingHours
    let notice: String?
    let sellerInfo: SellerInfo
}

protocol CafeRepository {
    func fetchCampusName() async throws -> String
    func fetchStores() async throws -> [Store]
}
