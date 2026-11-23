import SwiftUI

// 하단 CTA의 실제 높이를 재서, 스크롤 콘텐츠가 그 아래로 다 지나갈 수 있게 여백을 준다. (CartView와 동일한 패턴)
private struct BottomCTAHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel: OrderDetailViewModel
    @State private var bottomCTAHeight: CGFloat = 0

    private struct StepInfo {
        let label: String
        let time: Date?
        let color: Color
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
                        orderStepsSection
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
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: BottomCTAHeightKey.self, value: geometry.size.height)
                    }
                )
                .onPreferenceChange(BottomCTAHeightKey.self) { bottomCTAHeight = $0 }
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

    private var orderStepsSection: some View {
        VStack(spacing: Spacing.spacing8) {
            HStack(spacing: Spacing.spacing4) {
                ForEach(0..<barFillFractions.count, id: \.self) { index in
                    barSegment(index: index)
                }
            }

            HStack(spacing: Spacing.spacing4) {
                ForEach(steps.indices, id: \.self) { index in
                    let step = steps[index]
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
    private func barSegment(index: Int) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(Colors.fillBrandWeak)
                Rectangle()
                    .fill(barActiveColor(index: index))
                    .frame(width: geometry.size.width * barFillFractions[index])
                    .animation(.easeInOut(duration: 0.6), value: barFillFractions[index])
            }
        }
        .frame(height: 8)
        .clipShape(barShape(index: index, count: barFillFractions.count))
    }

    private func barActiveColor(index: Int) -> Color {
        viewModel.order.status == .cancelled && index == 0 ? Colors.fillDanger : Colors.fillBrand
    }

    private var barFillFractions: [CGFloat] {
        switch viewModel.order.status {
        case .confirming: [1, 0, 0, 0]
        case .making: [1, 1, 0, 0]
        case .waitingPickup: [1, 1, 1, 0]
        case .pickedUp: [1, 1, 1, 1]
        case .cancelled: [1, 0, 0, 0]
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
                case .pickedUp:
                    HStack(spacing: Spacing.spacing8) {
                        actionButton("재주문", textColor: Colors.textBrand, background: Colors.fillBrandWeak, action: reorderTapped)
                        actionButton("영수증 보기", textColor: Colors.textOnFill, background: Colors.fillBrand, action: {})
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
        // TODO: 4.4.1 주문 취소 확인 화면으로 이동 (이번 범위 밖)
    }

    private func chooseOtherMenuTapped() {
        router.path = NavigationPath()
    }

    private func reorderTapped() {
        router.path.append(HomeRoute.cart)
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
