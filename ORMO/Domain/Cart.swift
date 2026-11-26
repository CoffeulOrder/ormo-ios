import Foundation

enum PickupMethod: Hashable {
    case dineIn
    case takeout
}

enum PaymentMethod: Hashable, Codable {
    case card
    case tossPay
    case naverPay
    case kakaoPay

    var displayName: String {
        switch self {
        case .card: "신용·체크카드"
        case .tossPay: "토스페이"
        case .naverPay: "네이버페이"
        case .kakaoPay: "카카오페이"
        }
    }
}

struct CartLineItem: Identifiable, Hashable {
    let id: String
    let menuItemId: String
    let menuItemName: String
    var quantity: Int
    let unitPrice: Int
    let optionsSummary: String
    // 주문 생성 API(POST /orders)가 요구하는 실제 옵션 항목 ID. 재주문처럼 옵션을 다시 고른 적
    // 없는 경로에서는 빈 배열로 둔다(그런 주문은 어차피 서버에 새로 만들지 않거나, 옵션 없이도
    // 되는 메뉴를 가정한다).
    var optionItemIds: [String] = []
    // 담은 뒤 매장에서 품절 처리했을 때 true가 된다. 장바구니에는 남지만 결제 금액에서 빠진다.
    var isSoldOut: Bool = false

    var totalPrice: Int { unitPrice * quantity }
}

@Observable
final class CartStore {
    static let maxQuantityPerLine = 5

    static let maxPaymentFailureCount = 5

    private(set) var items: [CartLineItem] = []
    // 담기에 성공한 직후 한 번만 보여줄 스낵바 문구. 소비한 화면이 nil로 되돌린다.
    var justAddedMessage: String?
    // 삭제 직후 "되돌리기"와 함께 보여줄 스낵바 문구. 일정 시간 뒤 또는 되돌리면 nil이 된다.
    var removedItemMessage: String?
    // 같은 장바구니로 결제를 연달아 실패한 횟수. 5번째에 "더 이상 결제할 수 없음" 화면으로 바뀐다.
    private(set) var paymentFailureCount = 0

    private var lastRemoved: (item: CartLineItem, index: Int)?
    private var removalMessageTask: Task<Void, Never>?

    var totalQuantity: Int { items.reduce(0) { $0 + $1.quantity } }
    var totalPrice: Int { items.reduce(0) { $0 + $1.totalPrice } }
    // 품절된 메뉴는 매장이 만들 수 없어 결제 금액에서 빠진다. 목록에는 그대로 남아 사용자가 직접 빼거나 확인할 수 있다.
    var payableTotalPrice: Int { items.filter { !$0.isSoldOut }.reduce(0) { $0 + $1.totalPrice } }
    var isEmpty: Bool { items.isEmpty }

    func add(_ item: CartLineItem) {
        items.append(item)
        justAddedMessage = "장바구니에 메뉴를 추가했어요"
    }

    // "바로 주문" 흐름: 장바구니 화면으로 바로 넘어가므로 메뉴 홈의 담기 완료 토스트는 띄우지 않는다.
    func addSilently(_ item: CartLineItem) {
        items.append(item)
    }

    func increaseQuantity(_ itemId: String) {
        guard let index = items.firstIndex(where: { $0.id == itemId }), !items[index].isSoldOut else { return }
        guard items[index].quantity < Self.maxQuantityPerLine else { return }
        items[index].quantity += 1
    }

    func decreaseQuantity(_ itemId: String) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        guard items[index].quantity > 1 else { return }
        items[index].quantity -= 1
    }

    func remove(_ itemId: String) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        let removed = items.remove(at: index)
        lastRemoved = (removed, index)
        showRemovedMessage("\(removed.menuItemName.withObjectParticle) 삭제했어요")
    }

    func undoRemove() {
        guard let last = lastRemoved else { return }
        items.insert(last.item, at: min(last.index, items.count))
        lastRemoved = nil
        removalMessageTask?.cancel()
        removedItemMessage = nil
    }

    var isPaymentFailureLimitExceeded: Bool { paymentFailureCount >= Self.maxPaymentFailureCount }

    func recordPaymentFailure() {
        paymentFailureCount += 1
    }

    func resetPaymentFailureCount() {
        paymentFailureCount = 0
    }

    // 결제 성공: 이 주문은 끝났으니 장바구니와 실패 횟수를 모두 비운다.
    func clearAfterSuccessfulPayment() {
        items.removeAll()
        paymentFailureCount = 0
    }

    private func showRemovedMessage(_ message: String) {
        removedItemMessage = message
        removalMessageTask?.cancel()
        removalMessageTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            removedItemMessage = nil
            lastRemoved = nil
        }
    }
}

private extension String {
    // 받침 유무에 따라 "을" 또는 "를"을 붙인다. 한글 음절이 아니면(영문 등) "를"을 기본값으로 쓴다.
    var withObjectParticle: String {
        guard let scalar = unicodeScalars.last, (0xAC00...0xD7A3).contains(scalar.value) else { return self + "를" }
        let hasBatchim = (scalar.value - 0xAC00) % 28 != 0
        return self + (hasBatchim ? "을" : "를")
    }
}
