import Foundation

struct RemoteMenuRepository: MenuRepository {
    private struct StoreData: Decodable {
        let name: String
        let status: String
        let businessHours: [BusinessHourDTO]
    }

    private struct CategoryData: Decodable {
        let categoryId: Int
        let name: String
    }

    private struct MenuListItemData: Decodable {
        let menuId: Int
        let name: String
        let description: String?
        let basePrice: Int
        let soldOut: Bool
        let isNew: Bool
    }

    private struct OptionItemData: Decodable {
        let optionItemId: Int
        let name: String
        let priceDelta: Int
        let isDefault: Bool
        let soldOut: Bool
    }

    private struct OptionGroupData: Decodable {
        let optionGroupId: Int
        let name: String
        let required: Bool
        let maxSelect: Int
        let options: [OptionItemData]
    }

    private struct MenuDetailData: Decodable {
        let menuId: Int
        let name: String
        let description: String?
        let basePrice: Int
        let soldOut: Bool
        let optionGroups: [OptionGroupData]
    }

    func fetchStoreMenu(storeId: String) async throws -> StoreMenu {
        async let storeTask: StoreData = APIClient.shared.send(
            Endpoint(method: .get, path: "/api/v1/stores/\(storeId)"), decodingDataAs: StoreData.self
        )
        async let categoriesTask: [CategoryData] = APIClient.shared.send(
            Endpoint(method: .get, path: "/api/v1/stores/\(storeId)/categories"), decodingDataAs: [CategoryData].self
        )
        let (store, categoryList) = try await (storeTask, categoriesTask)

        let categories = try await withThrowingTaskGroup(of: (Int, MenuCategory).self) { group in
            for (index, category) in categoryList.enumerated() {
                group.addTask {
                    let items = try await fetchMenuItems(storeId: storeId, categoryId: category.categoryId)
                    return (index, MenuCategory(id: String(category.categoryId), name: category.name, items: items))
                }
            }
            var ordered: [(Int, MenuCategory)] = []
            for try await result in group {
                ordered.append(result)
            }
            return ordered.sorted { $0.0 < $1.0 }.map(\.1)
        }

        // 메뉴를 더는 받을 수 없는 건 영업 완전 종료(CLOSED)일 때뿐이다 — 잠깐 쉬는 중(PAUSED)엔
        // 메뉴는 그대로 보여주고, 결제 시점에 OrderAcceptance로 따로 막는다.
        let unavailableNotice: String? = store.status == "CLOSED"
            ? "\(StoreScheduleFormatting.nextOpeningText(from: store.businessHours))부터 다시 주문할 수 있어요"
            : nil

        return StoreMenu(
            storeName: store.name,
            // 최근 주문 메뉴를 주는 API가 없어 당분간 빈 배열로 둔다.
            recentOrders: [],
            categories: categories,
            unavailableNotice: unavailableNotice
        )
    }

    func fetchItemDetail(storeId: String, itemId: String) async throws -> MenuItemDetail {
        let endpoint = Endpoint(method: .get, path: "/api/v1/stores/\(storeId)/menus/\(itemId)")
        let detail: MenuDetailData = try await APIClient.shared.send(endpoint, decodingDataAs: MenuDetailData.self)

        let item = MenuItem(
            id: String(detail.menuId),
            name: detail.name,
            price: detail.basePrice,
            description: detail.description ?? "",
            badge: nil,
            isSoldOut: detail.soldOut
        )

        let optionGroups = detail.optionGroups.map { group -> MenuOptionGroup in
            let selectionType: MenuOptionSelectionType = group.maxSelect <= 1 ? .single : .multiple
            let defaultChoiceId = group.options.first(where: \.isDefault).map { String($0.optionItemId) }
            return MenuOptionGroup(
                id: String(group.optionGroupId),
                name: group.name,
                selectionType: selectionType,
                isRequired: group.required,
                defaultChoiceId: defaultChoiceId,
                maxSelectable: selectionType == .multiple ? group.maxSelect : nil,
                choices: group.options.map {
                    MenuOptionChoice(id: String($0.optionItemId), name: $0.name, priceDelta: $0.priceDelta, isSoldOut: $0.soldOut)
                }
            )
        }

        return MenuItemDetail(item: item, optionGroups: optionGroups)
    }

    private func fetchMenuItems(storeId: String, categoryId: Int) async throws -> [MenuItem] {
        let endpoint = Endpoint(
            method: .get,
            path: "/api/v1/stores/\(storeId)/menus",
            queryItems: [URLQueryItem(name: "categoryId", value: String(categoryId))],
            requiresAuth: false
        )
        let items: [MenuListItemData] = try await APIClient.shared.send(endpoint, decodingDataAs: [MenuListItemData].self)
        return items.map {
            MenuItem(
                id: String($0.menuId),
                name: $0.name,
                price: $0.basePrice,
                description: $0.description ?? "",
                badge: $0.isNew ? .new : nil,
                isSoldOut: $0.soldOut
            )
        }
    }
}
