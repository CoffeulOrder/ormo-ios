import Foundation

enum MenuBadge {
    case popular
    case new
}

struct MenuItem: Identifiable {
    let id: String
    let name: String
    let price: Int
    let description: String
    let badge: MenuBadge?
    let isSoldOut: Bool
}

struct MenuCategory: Identifiable {
    let id: String
    let name: String
    let items: [MenuItem]
}

struct StoreMenu {
    let storeName: String
    let recentOrders: [MenuItem]
    let categories: [MenuCategory]
}

protocol MenuRepository {
    func fetchStoreMenu() async throws -> StoreMenu
}
