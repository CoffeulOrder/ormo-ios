import Foundation

enum MenuBadge: Hashable {
    case popular
    case new
}

struct MenuItem: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Int
    let description: String
    let badge: MenuBadge?
    let isSoldOut: Bool
}

struct MenuCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let items: [MenuItem]
}

struct StoreMenu {
    let storeName: String
    let recentOrders: [MenuItem]
    let categories: [MenuCategory]
    // 매장이 영업시간 외라 지금은 주문할 수 없을 때, 메뉴 상단에 보여줄 안내 문구(예: "내일 14:30부터 다시 주문할 수 있어요").
    let unavailableNotice: String?

    var isEmpty: Bool { recentOrders.isEmpty && categories.isEmpty }
}

protocol MenuRepository {
    func fetchStoreMenu(storeId: String) async throws -> StoreMenu
}
