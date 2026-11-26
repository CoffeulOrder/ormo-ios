import SwiftUI

struct PaymentFailureView: View {
    @Environment(HomeRouter.self) private var router
    let cart: CartStore
    let orderId: Int
    let paymentMethod: PaymentMethod
    let totalPrice: Int
    let storeName: String
    let screensToClear: Int
    let orderRepository: OrderRepository

    init(
        cart: CartStore,
        orderId: Int,
        paymentMethod: PaymentMethod,
        totalPrice: Int,
        storeName: String,
        screensToClear: Int,
        orderRepository: OrderRepository = AppContainer.shared.orderRepository
    ) {
        self.cart = cart
        self.orderId = orderId
        self.paymentMethod = paymentMethod
        self.totalPrice = totalPrice
        self.storeName = storeName
        self.screensToClear = screensToClear
        self.orderRepository = orderRepository
    }

    private var isLimitExceeded: Bool { cart.isPaymentFailureLimitExceeded }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            OrmoSymbolView(badge: .init(color: Colors.fillDanger, icon: .closeIconSolid, iconSize: 20))

            textStack
                .padding(.top, Spacing.spacing56)

            Spacer()

            bottomCTA
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var textStack: some View {
        VStack(spacing: Spacing.spacing12) {
            Text(isLimitExceeded ? "더 이상 결제할 수 없어요" : "결제하지 못했어요")
                .typography(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)

            Group {
                if isLimitExceeded {
                    Text("결제를 5번 실패했어요")
                    Text("장바구니에서 다시 주문해주세요")
                } else {
                    Text("카드 상태를 확인하거나")
                    Text("다른 결제수단을 선택해주세요")
                }
            }
            .typography(Typography.bodyMdMedium)
            .foregroundStyle(Colors.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            VStack(spacing: Spacing.spacing8) {
                if isLimitExceeded {
                    actionButton("장바구니로 이동", style: .solid, action: backToCartTapped)
                } else {
                    actionButton("다시 결제하기", style: .solid, action: retryTapped)
                    actionButton("결제수단 변경하기", style: .weak, action: backToCartTapped)
                }
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private enum ActionButtonStyle {
        case solid
        case weak
    }

    private func actionButton(_ title: String, style: ActionButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(style == .solid ? Colors.textOnFill : Colors.textBrand)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(style == .solid ? Colors.fillBrand : Colors.fillBrandWeak)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
    }

    // router.path를 통째로 새 값으로 바꾸면 NavigationStack이 전환을 제대로 못 그려서 결제 확인
    // 중 화면이 멈춰 보이는 문제가 있었다. 그래서 장바구니까지 이어지는 화면들(screensToClear개,
    // 결제창 유무에 따라 2~3개)만 지우고 그 자리에 새 시도를 이어 붙인다 — 장바구니 화면은 새로
    // 만들지 않고 그대로 둔다. 재시도는 같은 paymentId를 재사용하지 않고, 서버에 새 결제 시도를
    // 받아온다(POST /orders/{orderId}/payment-attempts).
    private func retryTapped() {
        router.path.removeLast(screensToClear)
        Task {
            guard let fresh = try? await orderRepository.retryPaymentAttempt(orderId: orderId) else {
                return
            }
            if AppConfig.useMock {
                router.path.append(
                    HomeRoute.paymentProcessing(attemptId: UUID(), orderId: fresh.orderId, paymentId: fresh.paymentId, paymentMethod: paymentMethod, totalPrice: totalPrice, storeName: storeName)
                )
            } else {
                router.path.append(
                    HomeRoute.paymentCheckout(attemptId: UUID(), checkout: fresh, paymentMethod: paymentMethod, totalPrice: totalPrice, storeName: storeName)
                )
            }
        }
    }

    private func backToCartTapped() {
        if isLimitExceeded {
            cart.resetPaymentFailureCount()
        }
        router.path.removeLast(screensToClear)
    }
}

#Preview {
    PaymentFailureView(cart: CartStore(), orderId: 1, paymentMethod: .card, totalPrice: 12000, storeName: "을지대학교 범석관 카페", screensToClear: 2)
        .environment(HomeRouter())
}
