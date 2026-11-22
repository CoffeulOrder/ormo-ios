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

// 결제 시점에 매장이 실제로 주문을 받을 수 있는지. Store.status(목록 화면용 영업 중/종료)와 달리
// "오늘은 완전히 끝남"과 "브레이크타임처럼 잠깐 멈춤"을 구분해, 주문서에서 서로 다른 안내를 보여준다.
enum OrderAcceptance: Hashable {
    case accepting
    // 오늘 영업 종료. 다시 주문 가능한 시각 안내(예: "내일 08:30").
    case closedForToday(reopensAtText: String)
    // 같은 날 잠깐 주문만 중지(예: 브레이크타임). 다시 주문 가능한 시각 안내(예: "14:30").
    case paused(resumesAtText: String)
}

protocol CafeRepository {
    func fetchCampusName() async throws -> String
    func fetchStores() async throws -> [Store]
    func fetchOrderAcceptance(storeId: String) async throws -> OrderAcceptance
}
