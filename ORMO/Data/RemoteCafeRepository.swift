import Foundation

struct RemoteCafeRepository: CafeRepository {
    private struct StoreListItemData: Decodable {
        let storeId: Int
        let name: String
        let location: String
        let status: String
    }

    private struct SellerData: Decodable {
        let businessName: String
        let representativeName: String
        let businessRegNo: String
        let businessAddress: String
        let contactPhone: String
        // 통신판매신고번호는 입점 초반엔 아직 없는 매장이 많아 null로 올 수 있다.
        let mailOrderRegNo: String?
    }

    private struct StoreDetailData: Decodable {
        let storeId: Int
        let name: String
        let location: String
        let status: String
        let notice: String?
        let businessHours: [BusinessHourDTO]
        let seller: SellerData
    }

    private struct SchoolData: Decodable {
        let name: String
    }

    private struct MemberData: Decodable {
        let school: SchoolData
    }

    // 캠퍼스명을 주는 전용 API가 없어, 로그인한 회원의 소속 학교명(members/me)으로 대신한다.
    func fetchCampusName() async throws -> String {
        let endpoint = Endpoint(method: .get, path: "/api/v1/members/me")
        let data: MemberData = try await APIClient.shared.send(endpoint, decodingDataAs: MemberData.self)
        return data.school.name
    }

    func fetchStores() async throws -> [Store] {
        let listEndpoint = Endpoint(method: .get, path: "/api/v1/stores")
        let items: [StoreListItemData] = try await APIClient.shared.send(listEndpoint, decodingDataAs: [StoreListItemData].self)

        // 목록 응답엔 주소·영업시간·판매자 정보가 없어(상세 조회에만 있음), 매장별로 상세를 병렬로 받아 합친다.
        // 매장 하나의 상세 조회가 실패해도(데이터 이상 등) 나머지 매장까지 전부 못 뜨면 안 되니,
        // 실패한 매장은 목록 응답만으로 만든 자리표시 정보로 대체한다.
        return await withTaskGroup(of: (Int, Store).self) { group in
            for item in items {
                group.addTask {
                    if let store = try? await self.fetchStore(storeId: item.storeId) {
                        return (item.storeId, store)
                    }
                    return (item.storeId, self.fallbackStore(from: item))
                }
            }
            var ordered: [(Int, Store)] = []
            for await result in group {
                ordered.append(result)
            }
            let order = items.map(\.storeId)
            return ordered.sorted { order.firstIndex(of: $0.0) ?? 0 < order.firstIndex(of: $1.0) ?? 0 }.map(\.1)
        }
    }

    private func fallbackStore(from item: StoreListItemData) -> Store {
        let status: StoreOperatingStatus = switch item.status {
        case "PAUSED": .paused(resumesAtText: StoreScheduleFormatting.pausedResumeText)
        case "CLOSED": .closed
        default: .open
        }
        let unavailableHours = OperatingHours(weekdays: "정보 없음", saturday: "정보 없음", sundayAndHoliday: "정보 없음")

        return Store(
            id: String(item.storeId),
            name: item.name,
            status: status,
            address: "",
            distanceText: "-",
            walkTimeText: "-",
            location: item.location,
            operatingHours: unavailableHours,
            notice: nil,
            sellerInfo: SellerInfo(businessName: item.name, representative: "", registrationNumber: "", address: "", phoneNumber: "", mailOrderNumber: "")
        )
    }

    func fetchOrderAcceptance(storeId: String) async throws -> OrderAcceptance {
        guard let id = Int(storeId) else { return .accepting }
        let detail = try await fetchStoreDetail(storeId: id)
        switch detail.status {
        case "CLOSED":
            return .closedForToday(reopensAtText: StoreScheduleFormatting.nextOpeningText(from: detail.businessHours))
        case "PAUSED":
            return .paused(resumesAtText: StoreScheduleFormatting.pausedResumeText)
        default:
            return .accepting
        }
    }

    private func fetchStore(storeId: Int) async throws -> Store {
        let detail = try await fetchStoreDetail(storeId: storeId)

        let status: StoreOperatingStatus = switch detail.status {
        case "PAUSED": .paused(resumesAtText: StoreScheduleFormatting.pausedResumeText)
        case "CLOSED": .closed
        default: .open
        }

        return Store(
            id: String(detail.storeId),
            name: detail.name,
            status: status,
            // 매장 좌표가 서버에 없어 실제 거리·도보 시간은 계산할 수 없다 — 자리만 유지한다.
            address: detail.seller.businessAddress,
            distanceText: "-",
            walkTimeText: "-",
            location: detail.location,
            operatingHours: StoreScheduleFormatting.operatingHours(from: detail.businessHours),
            notice: detail.notice,
            sellerInfo: SellerInfo(
                businessName: detail.seller.businessName,
                representative: detail.seller.representativeName,
                registrationNumber: detail.seller.businessRegNo,
                address: detail.seller.businessAddress,
                phoneNumber: detail.seller.contactPhone,
                mailOrderNumber: detail.seller.mailOrderRegNo ?? "준비 중"
            )
        )
    }

    private func fetchStoreDetail(storeId: Int) async throws -> StoreDetailData {
        let endpoint = Endpoint(method: .get, path: "/api/v1/stores/\(storeId)")
        return try await APIClient.shared.send(endpoint, decodingDataAs: StoreDetailData.self)
    }
}
