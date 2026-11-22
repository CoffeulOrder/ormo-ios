import Foundation

@Observable
final class MenuOptionsViewModel {
    static let minQuantity = 1
    static let maxQuantity = 5

    let item: MenuItem
    var optionGroups: [MenuOptionGroup] = []
    var quantity = minQuantity
    var selectedSingleChoice: [String: String] = [:]
    var selectedMultipleChoices: [String: Set<String>] = [:]
    var isSnackbarVisible = false
    var snackbarMessage = ""
    var didAddToCart = false

    private let cart: CartStore
    private let menuRepository: MenuRepository
    private var snackbarTask: Task<Void, Never>?

    init(
        item: MenuItem,
        cart: CartStore,
        menuRepository: MenuRepository = MockMenuRepository()
    ) {
        self.item = item
        self.cart = cart
        self.menuRepository = menuRepository
    }

    var canIncreaseQuantity: Bool { quantity < Self.maxQuantity }
    var canDecreaseQuantity: Bool { quantity > Self.minQuantity }

    var unitPrice: Int { item.price + selectedOptionsPriceDelta }
    var totalPrice: Int { unitPrice * quantity }

    var isRequiredSelectionSatisfied: Bool {
        // 필수 배지가 붙어도 기본 선택지(defaultChoiceId)가 없는 그룹(예: 사이즈)은
        // "안 고름 = 기본 사이즈"가 유효한 상태라 [담기]를 막지 않는다.
        optionGroups
            .filter { $0.isRequired && $0.selectionType == .single && $0.defaultChoiceId != nil }
            .allSatisfy { selectedSingleChoice[$0.id] != nil }
    }

    func load() async {
        guard let detail = try? await menuRepository.fetchItemDetail(itemId: item.id) else { return }
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
        guard isRequiredSelectionSatisfied else { return }
        cart.add(
            CartLineItem(
                id: UUID().uuidString,
                menuItemId: item.id,
                menuItemName: item.name,
                quantity: quantity,
                unitPrice: unitPrice,
                optionsSummary: optionsSummary
            )
        )
        didAddToCart = true
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
            .joined(separator: " · ")
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
