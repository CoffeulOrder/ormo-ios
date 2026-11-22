import Foundation

struct CartLineItem: Identifiable, Hashable {
    let id: String
    let menuItemId: String
    let menuItemName: String
    let quantity: Int
    let unitPrice: Int
    let optionsSummary: String

    var totalPrice: Int { unitPrice * quantity }
}

@Observable
final class CartStore {
    private(set) var items: [CartLineItem] = []
    // 담기에 성공한 직후 한 번만 보여줄 스낵바 문구. 소비한 화면이 nil로 되돌린다.
    var justAddedMessage: String?

    var totalQuantity: Int { items.reduce(0) { $0 + $1.quantity } }
    var totalPrice: Int { items.reduce(0) { $0 + $1.totalPrice } }
    var isEmpty: Bool { items.isEmpty }

    func add(_ item: CartLineItem) {
        items.append(item)
        justAddedMessage = "장바구니에 메뉴를 추가했어요"
    }
}
