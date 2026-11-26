import Foundation

@Observable
final class MenuOptionsViewModel {
    static let minQuantity = 1
    static let maxQuantity = 5

    let storeId: String
    let item: MenuItem
    var optionGroups: [MenuOptionGroup] = []
    var quantity = minQuantity
    var selectedSingleChoice: [String: String] = [:]
    var selectedMultipleChoices: [String: Set<String>] = [:]
    var isSnackbarVisible = false
    var snackbarMessage = ""
    var didAddToCart = false
    // 필수 옵션을 안 고르고 담기/바로 주문을 눌렀을 때, 그 그룹으로 스크롤하라는 신호.
    // 같은 그룹을 연달아 가리켜도 매번 스크롤이 다시 일어나도록 groupId가 아니라 트리거 횟수로 관찰한다.
    var scrollTargetGroupId: String?
    var scrollTrigger = 0

    private let cart: CartStore
    private let menuRepository: MenuRepository
    private var snackbarTask: Task<Void, Never>?

    init(
        storeId: String,
        item: MenuItem,
        cart: CartStore,
        menuRepository: MenuRepository = AppContainer.shared.menuRepository
    ) {
        self.storeId = storeId
        self.item = item
        self.cart = cart
        self.menuRepository = menuRepository
    }

    var canIncreaseQuantity: Bool { quantity < Self.maxQuantity }
    var canDecreaseQuantity: Bool { quantity > Self.minQuantity }

    var unitPrice: Int { item.price + selectedOptionsPriceDelta }
    var totalPrice: Int { unitPrice * quantity }

    var isRequiredSelectionSatisfied: Bool {
        firstUnsatisfiedRequiredGroup == nil
    }

    private var firstUnsatisfiedRequiredGroup: MenuOptionGroup? {
        optionGroups.first {
            $0.isRequired && $0.selectionType == .single && selectedSingleChoice[$0.id] == nil
        }
    }

    func load() async {
        guard let detail = try? await menuRepository.fetchItemDetail(storeId: storeId, itemId: item.id) else { return }
        optionGroups = detail.optionGroups
        for group in detail.optionGroups {
            switch group.selectionType {
            case .single:
                selectedSingleChoice[group.id] = group.defaultChoiceId
            case .multiple:
                selectedMultipleChoices[group.id] = []
            }
        }
    }

    func increaseQuantity() {
        guard canIncreaseQuantity else { return }
        quantity += 1
    }

    func decreaseQuantity() {
        guard canDecreaseQuantity else { return }
        quantity -= 1
    }

    func isSelected(_ choice: MenuOptionChoice, in group: MenuOptionGroup) -> Bool {
        switch group.selectionType {
        case .single:
            selectedSingleChoice[group.id] == choice.id
        case .multiple:
            selectedMultipleChoices[group.id]?.contains(choice.id) ?? false
        }
    }

    func choiceTapped(_ choice: MenuOptionChoice, in group: MenuOptionGroup) {
        guard !choice.isSoldOut else { return }

        switch group.selectionType {
        case .single:
            selectedSingleChoice[group.id] = choice.id
        case .multiple:
            var selected = selectedMultipleChoices[group.id] ?? []
            if selected.contains(choice.id) {
                selected.remove(choice.id)
            } else if let max = group.maxSelectable, selected.count >= max {
                showSnackbar("최대 \(max)개까지 선택할 수 있어요")
                return
            } else {
                selected.insert(choice.id)
            }
            selectedMultipleChoices[group.id] = selected
        }
    }

    func addToCart() {
        guard validateRequiredSelections() else { return }
        cart.add(buildCartLineItem())
        didAddToCart = true
    }

    // "바로 주문": 장바구니에 조용히 담고 장바구니 화면으로 바로 넘어간다(메뉴 홈 토스트 없음).
    // 필수 옵션이 비어 있으면 평소처럼 스크롤+토스트를 띄우고 false를 반환한다.
    func orderNow() -> Bool {
        guard validateRequiredSelections() else { return false }
        cart.addSilently(buildCartLineItem())
        return true
    }

    private func buildCartLineItem() -> CartLineItem {
        CartLineItem(
            id: UUID().uuidString,
            menuItemId: item.id,
            menuItemName: item.name,
            quantity: quantity,
            unitPrice: unitPrice,
            optionsSummary: optionsSummary,
            optionItemIds: optionGroups.flatMap { selectedChoices(in: $0) }.map(\.id)
        )
    }

    // 필수 옵션을 다 골랐는지 확인한다. 못 고른 그룹이 있으면 그 그룹으로 스크롤하라는
    // 신호를 보내고 토스트를 띄운 뒤 false를 반환한다. 호출부(담기·바로 주문)는 그 뒤를 멈춰야 한다.
    @discardableResult
    func validateRequiredSelections() -> Bool {
        guard let missingGroup = firstUnsatisfiedRequiredGroup else { return true }
        scrollTargetGroupId = missingGroup.id
        scrollTrigger += 1
        showSnackbar("\(missingGroup.name) 옵션을 선택해 주세요")
        return false
    }

    private var selectedOptionsPriceDelta: Int {
        optionGroups.reduce(0) { total, group in
            total + selectedChoices(in: group).reduce(0) { $0 + $1.priceDelta }
        }
    }

    private var optionsSummary: String {
        optionGroups
            .flatMap { selectedChoices(in: $0) }
            .map(\.name)
            .joined(separator: " | ")
    }

    private func selectedChoices(in group: MenuOptionGroup) -> [MenuOptionChoice] {
        switch group.selectionType {
        case .single:
            guard let choiceId = selectedSingleChoice[group.id] else { return [] }
            return group.choices.filter { $0.id == choiceId }
        case .multiple:
            let selected = selectedMultipleChoices[group.id] ?? []
            return group.choices.filter { selected.contains($0.id) }
        }
    }

    private func showSnackbar(_ message: String) {
        snackbarMessage = message
        isSnackbarVisible = true
        snackbarTask?.cancel()
        snackbarTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isSnackbarVisible = false
        }
    }
}
