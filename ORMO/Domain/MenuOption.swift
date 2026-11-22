import Foundation

enum MenuOptionSelectionType: Hashable {
    case single
    case multiple
}

struct MenuOptionChoice: Identifiable, Hashable {
    let id: String
    let name: String
    let priceDelta: Int
    var isSoldOut: Bool = false
}

struct MenuOptionGroup: Identifiable, Hashable {
    let id: String
    let name: String
    let selectionType: MenuOptionSelectionType
    // 필수(Critical·Weak, "필수") · 선택(Brand·Weak, "선택") 배지는 이 값으로만 정해진다. (스펙: 307:4978)
    let isRequired: Bool
    // single 선택 그룹의 기본 선택값. 없으면 선택 없이 시작한다.
    let defaultChoiceId: String?
    // multiple 선택 그룹에서 고를 수 있는 최대 개수. nil이면 제한 없음.
    let maxSelectable: Int?
    let choices: [MenuOptionChoice]
}

struct MenuItemDetail: Hashable {
    let item: MenuItem
    let optionGroups: [MenuOptionGroup]
}
