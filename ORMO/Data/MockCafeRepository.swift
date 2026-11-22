import Foundation

struct MockCafeRepository: CafeRepository {
    func fetchCampusName() async throws -> String {
        "을지대학교"
    }

    func fetchStores() async throws -> [Store] {
        try? await Task.sleep(for: .seconds(0.3))

        let address = "경기도 성남시 수정구 상성대로 567번길 1층 일부호(양지동)"
        let hours = OperatingHours(weekdays: "08:30~18:00", saturday: "10:00~15:00", sundayAndHoliday: "쉬어요")

        func sellerInfo(name: String) -> SellerInfo {
            SellerInfo(
                businessName: name,
                representative: "김오르",
                registrationNumber: "123-45-67890",
                address: "경기도 성남시 수정구 산성대로 567번길 1층 (양지동)",
                phoneNumber: "031-000-0000",
                mailOrderNumber: "준비 중"
            )
        }

        return [
            Store(
                id: "beomseokgwan",
                name: "을지대학교 범석관 카페",
                status: .open,
                address: address,
                distanceText: "910m",
                walkTimeText: "14분",
                location: "범석관 1층 로비",
                operatingHours: hours,
                notice: "11월 20일(목)은 학교 행사로 14:00까지만 열어요",
                sellerInfo: sellerInfo(name: "을지대학교 범석관 카페")
            ),
            Store(
                id: "new-millennium",
                name: "을지대학교 뉴밀레니엄센터 카페",
                status: .closed,
                address: address,
                distanceText: "650m",
                walkTimeText: "9분",
                location: "뉴밀레니엄센터 1층",
                operatingHours: hours,
                notice: nil,
                sellerInfo: sellerInfo(name: "을지대학교 뉴밀레니엄센터 카페")
            ),
            Store(
                id: "bagaegwan",
                name: "을지대학교 박애관 카페",
                status: .open,
                address: address,
                distanceText: "1.2km",
                walkTimeText: "20분",
                location: "박애관 1층 로비",
                operatingHours: hours,
                notice: nil,
                sellerInfo: sellerInfo(name: "을지대학교 박애관 카페")
            )
        ]
    }
}
