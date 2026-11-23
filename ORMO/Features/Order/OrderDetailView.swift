import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel: OrderDetailViewModel

    // 팝업이 트리에 있는지(isDialogPresented)와 보이는 정도(scale·opacity)를 분리한다.
    // .transition()에 애니메이션을 붙이는 방식은 이 화면에서 실제로 재생되지 않았다(그냥 틱 하고
    // 나타남/사라짐). scaleEffect·opacity를 직접 들고 withAnimation으로 바꾸는 가장 기본적인 방식이
    // 확실히 동작한다. Figma 원본 수치(0.94→1, 212:5205)는 변화 폭이 6%뿐이라 오버슈트를 그대로
    // 구현해도 눈에 띄지 않아서, 통통 튀는 느낌이 보이도록 폭을 키우고 spring으로 바꿨다.
    @State private var isDialogPresented = false
    @State private var dialogScale: CGFloat = 0.7
    @State private var dialogOpacity: Double = 0
    @State private var dimOpacity: Double = 0
    @State private var dialogCloseTask: Task<Void, Never>?

    @State private var toast: ToastContent?
    @State private var toastTask: Task<Void, Never>?

    private static let dimAnimation = Animation.easeOut(duration: 0.2)
    private static let dialogOpenAnimation = Animation.spring(response: 0.32, dampingFraction: 0.62)
    private static let dialogCloseAnimation = Animation.easeOut(duration: 0.15)
    private static let dialogCloseDuration = 0.15

    // 버튼이 1개든 2개든 한 줄(56px 높이)이라 하단 CTA 전체 높이가 항상 같다(포그40+버튼56+하단여백32).
    // GeometryReader로 매번 재는 대신 고정값을 써서, 측정 전 프레임에 패딩이 모자라 보이는 걸 막는다.
    private let bottomCTAHeight: CGFloat = 128

    private struct StepInfo {
        let label: String
        let time: Date?
        let color: Color
    }

    private struct ToastContent: Equatable {
        let message: String
        let tone: Snackbar.Tone
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yy.MM.dd (E) HH:mm"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    init(pickupNumber: Int, storeName: String) {
        _viewModel = State(initialValue: OrderDetailViewModel(pickupNumber: pickupNumber, storeName: storeName))
    }

    // 프리뷰 전용: 특정 상태를 고정해서 보여준다.
    fileprivate init(order: Order) {
        _viewModel = State(initialValue: OrderDetailViewModel(order: order))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topNavigationBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        statusHeader
                        calloutSection
                        if showsOrderSteps {
                            orderStepsSection
                        }
                        thickDivider
                        orderItemsSection
                        thickDivider
                        paymentInfoSection
                    }
                    .padding(.bottom, bottomCTAHeight + Spacing.spacing8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            bottomCTA

            if let toast {
                Snackbar(message: toast.message, tone: toast.tone)
                    .padding(.bottom, bottomCTAHeight + Spacing.spacing16)
                    .transition(.opacity.animation(.easeOut(duration: 0.2)))
            }

            if isDialogPresented {
                ZStack {
                    Colors.backgroundDim
                        .ignoresSafeArea()
                        .opacity(dimOpacity)

                    AlertDialog(
                        title: "주문을 취소할까요?",
                        message: "결제 금액 전액을 환불해 드려요",
                        secondaryTitle: "닫기",
                        primaryTitle: "취소하기",
                        tone: .critical,
                        secondaryAction: { closeCancelDialog() },
                        primaryAction: confirmCancelTapped
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
        .task { viewModel.start() }
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("주문 상세")
                .font(Typography.bodyLgSemibold)
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

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing12) {
            Text(statusTitle)
                .font(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(viewModel.order.storeName) ∙ \(Self.dateFormatter.string(from: viewModel.order.paidAt))")
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing24)
    }

    private var showsOrderSteps: Bool {
        viewModel.order.status != .userCancelled
    }

    @ViewBuilder
    private var calloutSection: some View {
        switch viewModel.order.status {
        case .userCancelled:
            calloutView("결제한 금액은 모두 돌려드려요.\n카드사에 따라 3~5일 걸려요.")
        case .refunded:
            calloutView("결제한 수단으로 금액을 돌려드렸어요. 카드사에 따라 3~5일 걸려요")
        case .unclaimed:
            calloutView("환불이 필요하면 매장에 문의해주세요")
        default:
            EmptyView()
        }
    }

    private func calloutView(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing8) {
            Image(.calloutInfoIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(text)
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.spacing16)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutralWeak)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.spacing20)
        .padding(.bottom, Spacing.spacing20)
    }

    private var orderStepsSection: some View {
        VStack(spacing: Spacing.spacing8) {
            HStack(spacing: Spacing.spacing4) {
                // barFillFractions도 steps와 같은 이유로 한 번만 읽어서 넘긴다.
                ForEach(Array(barFillFractions.enumerated()), id: \.offset) { index, fraction in
                    barSegment(index: index, count: barFillFractions.count, fraction: fraction)
                }
            }

            HStack(spacing: Spacing.spacing4) {
                // steps는 상태에 따라 길이가 바뀌는 computed property라, .indices와 구독 두 번 호출하면
                // 애니메이션 전환 중 다른 상태값으로 평가돼 범위를 벗어날 수 있다. 한 번만 읽어서 쓴다.
                ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                    VStack(spacing: 0) {
                        Text(step.label)
                            .font(Typography.bodySmMedium)
                            .foregroundStyle(step.color)
                        if let time = step.time {
                            Text(Self.timeFormatter.string(from: time))
                                .font(Typography.bodyXsMedium)
                                .foregroundStyle(Colors.textTertiary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.bottom, Spacing.spacing24)
    }

    // 막대 사이는 4px씩 떨어져 있어서, 전체 묶음의 바깥쪽 끝(첫 막대 왼쪽·마지막 막대 오른쪽)만
    // 둥글고 나머지는 각진 모서리다. Figma 원본 반지름 4px(막대 높이 8px의 절반, 토큰 없음).
    private func barShape(index: Int, count: Int) -> UnevenRoundedRectangle {
        let radius: CGFloat = 4
        if index == 0 {
            return UnevenRoundedRectangle(topLeadingRadius: radius, bottomLeadingRadius: radius, bottomTrailingRadius: 0, topTrailingRadius: 0)
        } else if index == count - 1 {
            return UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: radius, topTrailingRadius: radius)
        } else {
            return UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 0)
        }
    }

    // 상태가 바뀔 때 색이 순간적으로 탁 바뀌지 않고, 칸이 왼쪽부터 부드럽게 차오르게 한다.
    private func barSegment(index: Int, count: Int, fraction: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(barTrackColor(index: index))
                Rectangle()
                    .fill(barActiveColor(index: index))
                    .frame(width: geometry.size.width * fraction)
                    .animation(.easeInOut(duration: 0.6), value: fraction)
            }
        }
        .frame(height: 8)
        .clipShape(barShape(index: index, count: count))
    }

    private func barActiveColor(index: Int) -> Color {
        viewModel.order.status == .cancelled && index == 0 ? Colors.fillDanger : Colors.fillBrand
    }

    // 미수령은 마지막 칸이 "아직 안 참" 파란색이 아니라 "다시는 안 참"이라는 뜻으로 회색이다.
    private func barTrackColor(index: Int) -> Color {
        viewModel.order.status == .unclaimed && index == 3 ? Colors.fillNeutralWeak : Colors.fillBrandWeak
    }

    private var barFillFractions: [CGFloat] {
        switch viewModel.order.status {
        case .confirming: [1, 0, 0, 0]
        case .making: [1, 1, 0, 0]
        case .waitingPickup: [1, 1, 1, 0]
        case .pickedUp: [1, 1, 1, 1]
        case .cancelled: [1, 0, 0, 0]
        case .userCancelled: [0, 0, 0, 0]
        case .refunded: [1, 1, 1, 1]
        case .unclaimed: [1, 1, 1, 0]
        }
    }

    private var steps: [StepInfo] {
        let order = viewModel.order
        switch order.status {
        case .confirming:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textBrand),
                StepInfo(label: "만드는 중", time: nil, color: Colors.textTertiary),
                StepInfo(label: "픽업 대기", time: nil, color: Colors.textTertiary),
                StepInfo(label: "픽업 완료", time: nil, color: Colors.textTertiary)
            ]
        case .making:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textSecondary),
                StepInfo(label: "만드는 중", time: order.madeAt, color: Colors.textBrand),
                StepInfo(label: "픽업 대기", time: nil, color: Colors.textTertiary),
                StepInfo(label: "픽업 완료", time: nil, color: Colors.textTertiary)
            ]
        case .waitingPickup:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textSecondary),
                StepInfo(label: "만드는 중", time: order.madeAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 대기", time: order.waitingAt, color: Colors.textBrand),
                StepInfo(label: "픽업 완료", time: nil, color: Colors.textTertiary)
            ]
        case .pickedUp:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textSecondary),
                StepInfo(label: "만드는 중", time: order.madeAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 대기", time: order.waitingAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 완료", time: order.pickedUpAt, color: Colors.textSecondary)
            ]
        case .cancelled:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textTertiary),
                StepInfo(label: "만드는 중", time: nil, color: Colors.textTertiary),
                StepInfo(label: "픽업 대기", time: nil, color: Colors.textTertiary),
                StepInfo(label: "픽업 완료", time: nil, color: Colors.textTertiary)
            ]
        case .userCancelled:
            return []
        case .refunded:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textSecondary),
                StepInfo(label: "만드는 중", time: order.madeAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 대기", time: order.waitingAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 완료", time: order.pickedUpAt, color: Colors.textBrand)
            ]
        case .unclaimed:
            return [
                StepInfo(label: "주문 확인 중", time: order.confirmedAt, color: Colors.textSecondary),
                StepInfo(label: "만드는 중", time: order.madeAt, color: Colors.textSecondary),
                StepInfo(label: "픽업 대기", time: order.waitingAt, color: Colors.textSecondary),
                StepInfo(label: "미수령", time: order.unclaimedAt, color: Colors.textDanger)
            ]
        }
    }

    private var statusTitle: String {
        let number = viewModel.order.pickupNumber
        switch viewModel.order.status {
        case .confirming: return "\(number)번 주문을 확인하고 있어요"
        case .making: return "\(number)번 주문을 만들고 있어요"
        case .waitingPickup: return "\(number)번 주문을 픽업해주세요"
        case .pickedUp: return "\(number)번 주문을 픽업했어요"
        case .cancelled: return "매장 사정으로\n주문이 취소됐어요"
        case .userCancelled: return "주문을 취소했어요"
        case .refunded: return "\(viewModel.order.subtotalPrice.formatted())원을 환불했어요"
        case .unclaimed: return "픽업 예정 시간이 지났어요"
        }
    }

    private var orderItemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("주문 내역")
                .font(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
                .padding(.horizontal, Spacing.spacing20)
                .padding(.vertical, Spacing.spacing12)

            VStack(alignment: .leading, spacing: Spacing.spacing16) {
                ForEach(viewModel.order.items) { item in
                    VStack(alignment: .leading, spacing: Spacing.spacing8) {
                        HStack(spacing: Spacing.spacing4) {
                            Text(item.name)
                                .font(Typography.bodyMdSemibold)
                                .foregroundStyle(Colors.textPrimary)
                            Text("\(item.quantity)개")
                                .font(Typography.bodySmMedium)
                                .foregroundStyle(Colors.textSecondary)
                        }
                        Text(item.optionsSummary)
                            .font(Typography.bodySmRegular)
                            .foregroundStyle(Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, Spacing.spacing12)
    }

    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("결제 정보")
                .font(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
                .padding(.vertical, Spacing.spacing12)

            VStack(spacing: Spacing.spacing12) {
                paymentRow("주문 금액", "\(viewModel.order.subtotalPrice.formatted())원")
                paymentRow("결제 수단", viewModel.order.paymentMethod.displayName)
                paymentRow("결제 일시", Self.dateFormatter.string(from: viewModel.order.paidAt))
            }
            .padding(.top, Spacing.spacing4)
            .padding(.bottom, Spacing.spacing16)

            thinDivider

            HStack {
                Text("총 결제 금액")
                Spacer()
                Text("\(viewModel.order.subtotalPrice.formatted())원")
            }
            .font(Typography.bodyLgBold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.top, Spacing.spacing16)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.bottom, Spacing.spacing24)
    }

    private func paymentRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(Colors.textTertiary)
            Spacer()
            Text(value).foregroundStyle(Colors.textPrimary)
        }
        .font(Typography.bodyMdRegular)
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

    @ViewBuilder
    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            Group {
                switch viewModel.order.status {
                case .confirming:
                    actionButton("주문 취소하기", textColor: Colors.textDanger, background: Colors.fillDangerWeak, action: cancelOrderTapped)
                case .making, .waitingPickup:
                    actionButton("주문 취소하기", textColor: Colors.textQuaternary, background: Colors.fillNeutralWeak, action: {})
                        .disabled(true)
                case .cancelled:
                    actionButton("다른 메뉴 고르기", textColor: Colors.textOnFill, background: Colors.fillBrand, action: chooseOtherMenuTapped)
                case .pickedUp, .userCancelled, .refunded, .unclaimed:
                    HStack(spacing: Spacing.spacing8) {
                        actionButton("재주문", textColor: Colors.textBrand, background: Colors.fillBrandWeak, action: reorderTapped)
                        actionButton("영수증 보기", textColor: Colors.textOnFill, background: Colors.fillBrand, action: viewReceiptTapped)
                            .frame(width: 200)
                    }
                }
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
    }

    private func actionButton(_ title: String, textColor: Color, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLgSemibold)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
    }

    private func cancelOrderTapped() {
        dialogCloseTask?.cancel()
        // 지난번 닫히다 만 값이 남아있을 수 있어, 보이기 전에 "숨은" 값으로 되돌려 놓고 그 다음 프레임에서
        // 목표값으로 애니메이션한다.
        dialogScale = 0.7
        dialogOpacity = 0
        dimOpacity = 0
        isDialogPresented = true
        withAnimation(Self.dimAnimation) {
            dimOpacity = 1
        }
        withAnimation(Self.dialogOpenAnimation) {
            dialogScale = 1
            dialogOpacity = 1
        }
    }

    // 닫는 애니메이션(0.15초)이 끝난 뒤에 뷰를 트리에서 빼고, 그 다음에야 onFinished를 실행한다.
    // 취소 성공 시 order.status 변경(진행바 섹션이 사라지는 구조 변경)이 팝업이 흐려지는 도중에
    // 겹치면, 흐릿하게 비치는 팝업 너머로 레이아웃이 재배치되는 게 보여서 줄이 생긴 것처럼 보였다.
    private func closeCancelDialog(then onFinished: (() -> Void)? = nil) {
        withAnimation(Self.dialogCloseAnimation) {
            dialogScale = 0.94
            dialogOpacity = 0
            dimOpacity = 0
        }
        dialogCloseTask?.cancel()
        dialogCloseTask = Task {
            try? await Task.sleep(for: .seconds(Self.dialogCloseDuration))
            guard !Task.isCancelled else { return }
            isDialogPresented = false
            onFinished?()
        }
    }

    // 팝업이 떠 있는 동안 매장이 먼저 주문을 수락했을 수 있어서, 실제 취소 전에 상태를 다시 확인한다.
    private func confirmCancelTapped() {
        let shouldCancel = viewModel.order.status == .confirming
        closeCancelDialog {
            if shouldCancel {
                viewModel.cancelOrder()
                showToast(message: "주문을 취소했어요", tone: .positive)
            } else {
                showToast(message: "주문이 접수되어 취소할 수 없어요", tone: .critical)
            }
        }
    }

    private func showToast(message: String, tone: Snackbar.Tone) {
        toast = ToastContent(message: message, tone: tone)
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            toast = nil
        }
    }

    private func chooseOtherMenuTapped() {
        router.path = NavigationPath()
    }

    private func reorderTapped() {
        router.path.append(HomeRoute.cart)
    }

    private func viewReceiptTapped() {
        let order = viewModel.order
        router.path.append(
            HomeRoute.receipt(pickupNumber: order.pickupNumber, storeName: order.storeName, totalPrice: order.subtotalPrice, paidAt: order.paidAt)
        )
    }
}

private func previewOrder(status: OrderStatus) -> Order {
    let now = Date()
    var order = Order.mock(pickupNumber: 27, storeName: "범석관 카페")
    order.status = status
    switch status {
    case .confirming:
        break
    case .making:
        order.madeAt = now
    case .waitingPickup:
        order.madeAt = now
        order.waitingAt = now
    case .cancelled:
        break
    case .pickedUp:
        order.madeAt = now
        order.waitingAt = now
        order.pickedUpAt = now
    case .userCancelled:
        order.userCancelledAt = now
    case .refunded:
        order.madeAt = now
        order.waitingAt = now
        order.pickedUpAt = now
        order.refundedAt = now
    case .unclaimed:
        order.madeAt = now
        order.waitingAt = now
        order.unclaimedAt = now
    }
    return order
}

#Preview("주문 확인 중") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .confirming))
    }
    .environment(HomeRouter())
}

#Preview("만드는 중") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .making))
    }
    .environment(HomeRouter())
}

#Preview("픽업 대기") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .waitingPickup))
    }
    .environment(HomeRouter())
}

#Preview("매장 취소") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .cancelled))
    }
    .environment(HomeRouter())
}

#Preview("픽업 완료") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .pickedUp))
    }
    .environment(HomeRouter())
}

#Preview("주문 취소") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .userCancelled))
    }
    .environment(HomeRouter())
}

#Preview("환불 완료") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .refunded))
    }
    .environment(HomeRouter())
}

#Preview("미수령") {
    NavigationStack {
        OrderDetailView(order: previewOrder(status: .unclaimed))
    }
    .environment(HomeRouter())
}
