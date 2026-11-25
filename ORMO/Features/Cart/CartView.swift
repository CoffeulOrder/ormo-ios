import SwiftUI

// 하단 CTA의 실제 높이를 재서, 스크롤 콘텐츠가 그 아래로 다 지나갈 수 있게 여백을 주고
// 토스트도 그만큼 띄워서 가려지지 않게 한다.
private struct BottomCTAHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel: CartViewModel
    @State private var bottomCTAHeight: CGFloat = 0
    @State private var dimOpacity: Double = 0
    @State private var dialogScale: CGFloat = 0.94
    @State private var dialogOpacity: Double = 0

    let onOrderUnavailable: () -> Void

    init(cart: CartStore, store: Store?, onOrderUnavailable: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: CartViewModel(cart: cart, store: store))
        self.onOrderUnavailable = onOrderUnavailable
    }

    var body: some View {
        ZStack {
            Group {
                if viewModel.cart.isEmpty {
                    emptyStateContent
                } else {
                    orderFormContent
                }
            }

            if let alert = viewModel.orderUnavailableAlert {
                ZStack {
                    Colors.backgroundDim
                        .ignoresSafeArea()
                        .opacity(dimOpacity)

                    AlertDialog(
                        title: alert.title,
                        message: alert.message,
                        primaryTitle: "확인",
                        primaryAction: {
                            viewModel.orderUnavailableAlert = nil
                            onOrderUnavailable()
                        }
                    )
                    .scaleEffect(dialogScale)
                    .opacity(dialogOpacity)
                    .compositingGroup()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: viewModel.orderUnavailableAlert) {
            if viewModel.orderUnavailableAlert != nil {
                // Figma smart-animate 타이밍: Dim 0~10%(200ms), Dialog 2.5~15%(지연 50ms, scale 250ms·opacity 200ms)
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 1
                }
                withAnimation(.timingCurve(0.45, 1.45, 0.8, 1, duration: 0.25).delay(0.05)) {
                    dialogScale = 1
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
                    dialogOpacity = 1
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 0
                    dialogScale = 0.94
                    dialogOpacity = 0
                }
            }
        }
        .onChange(of: viewModel.didStartPayment) {
            guard viewModel.didStartPayment else { return }
            viewModel.didStartPayment = false
            router.path.append(
                HomeRoute.paymentProcessing(
                    attemptId: UUID(),
                    paymentMethod: viewModel.paymentMethod,
                    totalPrice: viewModel.checkoutTotalPrice,
                    storeName: viewModel.store?.name ?? ""
                )
            )
        }
    }

    private var emptyStateContent: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ResultView(
                icon: .cartIcon,
                title: "장바구니가 비어 있어요",
                message: nil,
                buttonTitle: "메뉴 보기",
                action: { dismiss() }
            )
            .padding(.top, 129)
            Spacer()
        }
    }

    private var orderFormContent: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topNavigationBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        pickupSection
                        thickDivider
                        orderMenuSection
                        thickDivider
                        paymentSection
                    }
                    // 콘텐츠가 하단 CTA 뒤로 지나가며 포그에 자연스럽게 가려지도록, CTA 높이만큼 여백을 둔다.
                    // 여기에 약간 더 띄워서(spacing8) 마지막 콘텐츠가 포그에 바로 붙어 보이지 않게 한다.
                    .padding(.bottom, bottomCTAHeight + Spacing.spacing8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // 스크롤 콘텐츠 위에 겹쳐야 포그가 실제로 콘텐츠를 흐리게 덮는 효과가 난다.
            bottomCTA
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: BottomCTAHeightKey.self, value: geometry.size.height)
                    }
                )
                .onPreferenceChange(BottomCTAHeightKey.self) { bottomCTAHeight = $0 }

            if let message = viewModel.cart.removedItemMessage {
                removalSnackbar(message)
                    .padding(.bottom, bottomCTAHeight + 2) // 2px 여백 (스페이싱 토큰 중 일치 항목 없음)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.cart.removedItemMessage)
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("장바구니")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)

            HStack(spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(.arrowBackIos)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var pickupSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("수령 방법")
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textPrimary)
                    .padding(.vertical, Spacing.spacing12)

                VStack(alignment: .leading, spacing: Spacing.spacing8) {
                    Text(viewModel.store?.name ?? "")
                        .typography(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textPrimary)
                    if let address = viewModel.store?.address {
                        Text(address)
                            .typography(Typography.bodySmRegular)
                            .foregroundStyle(Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing20)

            thinDivider

            VStack(alignment: .leading, spacing: Spacing.spacing12) {
                pickupRow("매장 섭취", method: .dineIn)
                pickupRow("테이크아웃", method: .takeout)
            }
            .padding(Spacing.spacing20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func pickupRow(_ title: String, method: PickupMethod) -> some View {
        Button(action: { viewModel.pickupMethod = method }) {
            HStack(spacing: Spacing.spacing12) {
                radioControl(isSelected: viewModel.pickupMethod == method)
                Text(title)
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textPrimary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    private var orderMenuSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("주문 메뉴")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
                .padding(.horizontal, Spacing.spacing20)
                .padding(.vertical, Spacing.spacing12)

            ForEach(viewModel.cart.items) { item in
                lineItemRow(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func lineItemRow(_ item: CartLineItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing4) {
            HStack(spacing: Spacing.spacing8) {
                Text(item.menuItemName)
                    .typography(Typography.bodyMdSemibold)
                    .foregroundStyle(item.isSoldOut ? Colors.textQuaternary : Colors.textPrimary)

                if item.isSoldOut {
                    Text("품절")
                        .typography(Typography.bodyXsMedium)
                        .foregroundStyle(Colors.textSecondary)
                        .padding(.horizontal, Spacing.spacing8)
                        .frame(height: 24)
                        .background(Colors.fillNeutralWeak)
                        .clipShape(Capsule())
                }
            }

            Text(item.optionsSummary)
                .typography(Typography.bodySmMedium)
                .foregroundStyle(item.isSoldOut ? Colors.textQuaternary : Colors.textSecondary)

            HStack(spacing: 10) {
                Text("\(item.totalPrice.formatted())원")
                    .typography(Typography.bodyMdSemibold)
                    .foregroundStyle(item.isSoldOut ? Colors.textQuaternary : Colors.textPrimary)
                    .strikethrough(item.isSoldOut)
                    .frame(maxWidth: .infinity, alignment: .leading)

                cartQuantityPicker(item)
            }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cartQuantityPicker(_ item: CartLineItem) -> some View {
        let canIncrease = item.quantity < CartStore.maxQuantityPerLine && !item.isSoldOut

        return HStack(spacing: 0) {
            Button(action: { decreaseOrRemove(item) }) {
                Group {
                    if item.quantity > 1 {
                        Image(.minusIcon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Colors.textStrong)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(.trashIcon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Colors.textStrong)
                            .frame(width: 16, height: 16)
                    }
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Colors.fillNeutralWeak)
                .frame(width: 1, height: 16)

            Text("\(item.quantity)")
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(item.isSoldOut ? Colors.textQuaternary : Colors.textStrong)
                .frame(minWidth: 36)
                .padding(.horizontal, Spacing.spacing8)

            Rectangle()
                .fill(Colors.fillNeutralWeak)
                .frame(width: 1, height: 16)

            Button(action: { viewModel.cart.increaseQuantity(item.id) }) {
                Image(.plusIcon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(canIncrease ? Colors.textStrong : Colors.textQuaternary)
                    .frame(width: 16, height: 16)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(!canIncrease)
        }
        .frame(height: 40)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Colors.fieldBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private func decreaseOrRemove(_ item: CartLineItem) {
        if item.quantity > 1 {
            viewModel.cart.decreaseQuantity(item.id)
        } else {
            viewModel.cart.remove(item.id)
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("결제수단")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
                .padding(.horizontal, Spacing.spacing20)
                .padding(.top, Spacing.spacing12)

            VStack(alignment: .leading, spacing: Spacing.spacing16) {
                paymentRow("신용·체크카드", method: .card)
                paymentRow("토스페이", method: .tossPay)
                paymentRow("네이버페이", method: .naverPay)
                paymentRow("카카오페이", method: .kakaoPay)
            }
            .padding(Spacing.spacing20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func paymentRow(_ title: String, method: PaymentMethod) -> some View {
        Button(action: { viewModel.paymentMethod = method }) {
            HStack(spacing: Spacing.spacing12) {
                radioControl(isSelected: viewModel.paymentMethod == method)
                Text(title)
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textPrimary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    private func radioControl(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Colors.fillBrand : Color.clear)
            Circle()
                .strokeBorder(Colors.fieldBorder, lineWidth: isSelected ? 0 : 2)
            if isSelected {
                Circle()
                    .fill(Colors.textOnFill)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: 20, height: 20)
    }

    private var thinDivider: some View {
        Rectangle()
            .fill(Colors.borderDefault)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private var thickDivider: some View {
        Rectangle()
            .fill(Colors.backgroundLower)
            .frame(height: 12)
            .frame(maxWidth: .infinity)
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            VStack(spacing: 0) {
                Button(action: { viewModel.hasAgreedToNoCancellation.toggle() }) {
                    HStack(spacing: Spacing.spacing12) {
                        checkboxControl(isSelected: viewModel.hasAgreedToNoCancellation)
                        Text("매장이 주문을 받은 뒤에는 취소할 수 없어요")
                            .typography(Typography.bodyMdRegular)
                            .foregroundStyle(Colors.textPrimary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.spacing20)
                .padding(.top, Spacing.spacing12)
                .padding(.bottom, Spacing.spacing16)

                Button(action: { viewModel.checkoutTapped() }) {
                    Text("\(viewModel.checkoutTotalPrice.formatted())원 결제하기")
                        .typography(Typography.bodyLgSemibold)
                        .foregroundStyle(viewModel.isCheckoutEnabled ? Colors.textOnFill : Colors.textQuaternary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.isCheckoutEnabled ? Colors.fillBrand : Colors.fillNeutralWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isCheckoutEnabled)
                .padding(.horizontal, Spacing.spacing20)

                Button(action: { dismiss() }) {
                    Text("메뉴 추가하기")
                        .typography(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textTertiary)
                        .frame(height: 40)
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.spacing4)
            }
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // 이 체크박스는 안 골랐을 때도 체크 표시가 보인다: 안 고르면 회색 원, 고르면 파란 원(흰 체크는 항상 그대로).
    // 마크는 Figma Checkbox 전용 "Mark" 아이콘(16px, 원 20px 안)을 쓴다 — 범용 Icon/check(24px)와는 다른 비율이다.
    private func checkboxControl(isSelected: Bool) -> some View {
        Circle()
            .fill(isSelected ? Colors.fillBrand : Colors.fieldBorder)
            .overlay {
                Image(.checkboxMark)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Colors.textOnFill)
                    .frame(width: 16, height: 16)
            }
            .frame(width: 20, height: 20)
    }

    private func removalSnackbar(_ message: String) -> some View {
        HStack(spacing: Spacing.spacing12) {
            Text(message)
                .typography(Typography.bodyMdSemibold)
                .foregroundStyle(Colors.textOnFill)

            Button(action: { viewModel.cart.undoRemove() }) {
                Text("되돌리기")
                    .typography(Typography.bodySmSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .padding(.horizontal, Spacing.spacing12)
                    .padding(.vertical, Spacing.spacing4)
                    .background(Colors.textOnFill.opacity(0.19))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, Spacing.spacing20)
        .padding(.trailing, Spacing.spacing12)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutral)
        .clipShape(Capsule())
    }
}

#Preview {
    let cart = CartStore()
    cart.addSilently(
        CartLineItem(id: "1", menuItemId: "coffee-1", menuItemName: "아메리카노", quantity: 1, unitPrice: 4000, optionsSummary: "ICE | 오리지널 원두")
    )
    cart.addSilently(
        CartLineItem(id: "2", menuItemId: "coffee-1", menuItemName: "아메리카노", quantity: 3, unitPrice: 4000, optionsSummary: "ICE | 오리지널 원두")
    )
    return CartView(
        cart: cart,
        store: Store(
            id: "beomseokgwan",
            name: "을지대학교 범석관 카페",
            status: .open,
            address: "경기도 성남시 수정구 상성대로 567번길 1층 일부호(양지동)",
            distanceText: "910m",
            walkTimeText: "14분",
            location: "범석관 1층 로비",
            operatingHours: OperatingHours(weekdays: "08:30~18:00", saturday: "10:00~15:00", sundayAndHoliday: "쉬어요"),
            notice: nil,
            sellerInfo: SellerInfo(businessName: "", representative: "", registrationNumber: "", address: "", phoneNumber: "", mailOrderNumber: "")
        )
    )
}
