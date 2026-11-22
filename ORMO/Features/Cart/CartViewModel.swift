import Foundation

@Observable
final class CartViewModel {
    let cart: CartStore
    let store: Store?
    // Figma 기본값: 테이크아웃 · 토스페이가 미리 선택되어 있다.
    var pickupMethod: PickupMethod = .takeout
    var paymentMethod: PaymentMethod = .tossPay
    // 주문마다 다시 체크해야 한다(미리 체크 금지) — 화면을 새로 열 때마다 false로 시작한다.
    var hasAgreedToNoCancellation = false

    init(cart: CartStore, store: Store?) {
        self.cart = cart
        self.store = store
    }

    var isCheckoutEnabled: Bool { hasAgreedToNoCancellation && !cart.isEmpty }
    var checkoutTotalPrice: Int { cart.payableTotalPrice }

    func checkoutTapped() {
        // TODO: 3.2.2 결제 확인 중 → 주문 완료 화면으로 이동
    }
}
