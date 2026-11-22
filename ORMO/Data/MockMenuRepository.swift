import Foundation

struct MockMenuRepository: MenuRepository {
    func fetchStoreMenu(storeId: String) async throws -> StoreMenu {
        try? await Task.sleep(for: .seconds(0.3))

        switch storeId {
        case "bagaegwan":
            return StoreMenu(
                storeName: "을지대학교 박애관 카페",
                recentOrders: [],
                categories: [],
                unavailableNotice: nil
            )
        case "new-millennium":
            return StoreMenu(
                storeName: "을지대학교 뉴밀레니엄센터 카페",
                recentOrders: recentOrders,
                categories: categories,
                unavailableNotice: "내일 14:30부터 다시 주문할 수 있어요"
            )
        default:
            return StoreMenu(
                storeName: "을지대학교 범석관 카페",
                recentOrders: recentOrders,
                categories: categories,
                unavailableNotice: nil
            )
        }
    }

    func fetchItemDetail(itemId: String) async throws -> MenuItemDetail {
        try? await Task.sleep(for: .seconds(0.3))

        let allItems = recentOrders + categories.flatMap(\.items)
        let item = allItems.first { $0.id == itemId } ?? MenuItem(
            id: itemId,
            name: "아메리카노",
            price: 4000,
            description: "산미가 적고 고소한 원두로 내린 기본 커피예요. 진하게 마시려면 샷을 추가해 보세요.",
            badge: nil,
            isSoldOut: false
        )

        return MenuItemDetail(item: item, optionGroups: optionGroups)
    }

    private var optionGroups: [MenuOptionGroup] {
        [
            MenuOptionGroup(
                id: "temperature",
                name: "HOT / ICE",
                selectionType: .single,
                isRequired: true,
                defaultChoiceId: "ice",
                maxSelectable: nil,
                choices: [
                    MenuOptionChoice(id: "hot", name: "HOT", priceDelta: 0),
                    MenuOptionChoice(id: "ice", name: "ICE", priceDelta: 0)
                ]
            ),
            MenuOptionGroup(
                id: "bean",
                name: "원두 선택",
                selectionType: .single,
                isRequired: true,
                defaultChoiceId: "original",
                maxSelectable: nil,
                choices: [
                    MenuOptionChoice(id: "original", name: "오리지널 원두", priceDelta: 0),
                    MenuOptionChoice(id: "blend", name: "블렌드 원두", priceDelta: 0)
                ]
            ),
            // 사이즈는 명세(307:4978)상 필수 그룹이고 추가금 없는 기본 선택지가 없어
            // 기본값 없이 시작한다. 안 고르고 담기/바로 주문을 누르면 이 그룹으로 스크롤하고 토스트를 띄운다.
            MenuOptionGroup(
                id: "size",
                name: "사이즈",
                selectionType: .single,
                isRequired: true,
                defaultChoiceId: nil,
                maxSelectable: nil,
                choices: [
                    MenuOptionChoice(id: "sizeUp", name: "사이즈업", priceDelta: 900),
                    MenuOptionChoice(id: "doubleSizeUp", name: "두 배 사이즈업", priceDelta: 1800)
                ]
            ),
            MenuOptionGroup(
                id: "shotSyrup",
                name: "샷 / 시럽 추가",
                selectionType: .multiple,
                isRequired: false,
                defaultChoiceId: nil,
                maxSelectable: 2,
                choices: [
                    MenuOptionChoice(id: "light", name: "연하게", priceDelta: 0),
                    MenuOptionChoice(id: "shot1", name: "1샷 추가", priceDelta: 900),
                    MenuOptionChoice(id: "shot2", name: "2샷 추가", priceDelta: 1200),
                    MenuOptionChoice(id: "syrup", name: "시럽 추가", priceDelta: 1600)
                ]
            )
        ]
    }

    private var americano: String { "깔끔하고 산뜻한 기본 커피예요" }

    private var recentOrders: [MenuItem] {
        [
            MenuItem(id: "recent-1", name: "아메리카노", price: 4000, description: americano, badge: .popular, isSoldOut: false),
            MenuItem(id: "recent-2", name: "아메리카노", price: 4000, description: americano, badge: .new, isSoldOut: false),
            MenuItem(id: "recent-3", name: "아메리카노", price: 4000, description: americano, badge: nil, isSoldOut: true)
        ]
    }

    private var categories: [MenuCategory] {
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

        return [coffee, dessert, ade, smoothie, beverage]
    }
}
