import Foundation

struct MockMenuRepository: MenuRepository {
    func fetchStoreMenu() async throws -> StoreMenu {
        try? await Task.sleep(for: .seconds(0.3))

        let americano = "깔끔하고 산뜻한 기본 커피예요"

        let recentOrders = [
            MenuItem(id: "recent-1", name: "아메리카노", price: 4000, description: americano, badge: .popular, isSoldOut: false),
            MenuItem(id: "recent-2", name: "아메리카노", price: 4000, description: americano, badge: .new, isSoldOut: false),
            MenuItem(id: "recent-3", name: "아메리카노", price: 4000, description: americano, badge: nil, isSoldOut: true)
        ]

        let coffee = MenuCategory(
            id: "coffee",
            name: "커피",
            items: [
                MenuItem(id: "coffee-1", name: "아메리카노", price: 4000, description: americano, badge: .popular, isSoldOut: false),
                MenuItem(id: "coffee-2", name: "아메리카노", price: 4000, description: americano, badge: .new, isSoldOut: false),
                MenuItem(id: "coffee-3", name: "아메리카노", price: 4000, description: americano, badge: nil, isSoldOut: false),
                MenuItem(id: "coffee-4", name: "아메리카노", price: 4000, description: americano, badge: .popular, isSoldOut: false)
            ]
        )

        // 디저트·에이드·스무디·음료는 Figma에 상세 메뉴가 없어 임시 목업 항목으로 채운다.
        let dessert = MenuCategory(
            id: "dessert",
            name: "디저트",
            items: [
                MenuItem(id: "dessert-1", name: "크루아상", price: 3500, description: "겉은 바삭, 속은 촉촉한 버터 크루아상", badge: nil, isSoldOut: false),
                MenuItem(id: "dessert-2", name: "치즈케이크", price: 5500, description: "진하고 부드러운 뉴욕 치즈케이크", badge: nil, isSoldOut: false)
            ]
        )
        let ade = MenuCategory(
            id: "ade",
            name: "에이드",
            items: [
                MenuItem(id: "ade-1", name: "자몽에이드", price: 4500, description: "상큼한 자몽과 탄산의 조화", badge: nil, isSoldOut: false),
                MenuItem(id: "ade-2", name: "청포도에이드", price: 4500, description: "달콤한 청포도 과육이 들어간 에이드", badge: nil, isSoldOut: false)
            ]
        )
        let smoothie = MenuCategory(
            id: "smoothie",
            name: "스무디",
            items: [
                MenuItem(id: "smoothie-1", name: "딸기스무디", price: 5000, description: "제철 딸기로 만든 진한 스무디", badge: nil, isSoldOut: false),
                MenuItem(id: "smoothie-2", name: "망고스무디", price: 5000, description: "달콤한 망고가 가득한 스무디", badge: nil, isSoldOut: false)
            ]
        )
        let beverage = MenuCategory(
            id: "beverage",
            name: "음료",
            items: [
                MenuItem(id: "beverage-1", name: "복숭아 아이스티", price: 4000, description: "향긋한 복숭아 향이 나는 아이스티", badge: nil, isSoldOut: false),
                MenuItem(id: "beverage-2", name: "레몬에이드", price: 4000, description: "새콤달콤한 레몬에이드", badge: nil, isSoldOut: false)
            ]
        )

        return StoreMenu(
            storeName: "범석관 카페",
            recentOrders: recentOrders,
            categories: [coffee, dessert, ade, smoothie, beverage]
        )
    }
}
