import Foundation

struct OrderUnavailableAlert: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
}

@Observable
final class CartViewModel {
    let cart: CartStore
    let store: Store?
    // Figma 기본값: 테이크아웃 · 토스페이가 미리 선택되어 있다.
    var pickupMethod: PickupMethod = .takeout
    var paymentMethod: PaymentMethod = .tossPay
    // 주문마다 다시 체크해야 한다(미리 체크 금지) — 화면을 새로 열 때마다 false로 시작한다.
    var hasAgreedToNoCancellation = false
    // nil이 아니면 "매장이 지금 주문을 못 받는다"는 Alert Dialog를 띄운다.
    var orderUnavailableAlert: OrderUnavailableAlert?

    private let cafeRepository: CafeRepository

    init(cart: CartStore, store: Store?, cafeRepository: CafeRepository = MockCafeRepository()) {
        self.cart = cart
        self.store = store
        self.cafeRepository = cafeRepository
    }

    var isCheckoutEnabled: Bool { hasAgreedToNoCancellation && !cart.isEmpty }
    var checkoutTotalPrice: Int { cart.payableTotalPrice }

    func checkoutTapped() {
        guard let store else { return }
        Task {
            let acceptance = (try? await cafeRepository.fetchOrderAcceptance(storeId: store.id)) ?? .accepting
            switch acceptance {
            case .accepting:
                break // TODO: 3.2.2 결제 확인 중 → 주문 완료 화면으로 이동
            case .closedForToday(let reopensAtText):
                orderUnavailableAlert = OrderUnavailableAlert(
                    title: "오늘 영업이 끝났어요",
                    message: "\(reopensAtText)부터 주문할 수 있어요"
                )
            case .paused(let resumesAtText):
                orderUnavailableAlert = OrderUnavailableAlert(
                    title: "매장이 잠시 주문을 받지 않아요",
                    message: "\(resumesAtText)부터 다시 주문할 수 있어요"
                )
            }
        }
    }
}
