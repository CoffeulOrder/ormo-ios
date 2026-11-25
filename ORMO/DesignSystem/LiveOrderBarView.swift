import SwiftUI

// Live Order Bar — 결제한 주문이 픽업될 때까지 메뉴 홈 아래에 떠 있는 실시간 주문 현황.
// 닫기(X) 없음. 전체가 하나의 버튼으로 주문 상세로 이동한다. 단계는 색 + 글자로 함께 보여준다(WCAG 1.4.1).
struct LiveOrderBarView: View {
    let order: LiveOrder
    let action: () -> Void

    private var isReady: Bool { order.stage == .readyForPickup }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.spacing12) {
                topRow
                stepsView
            }
            .padding(Spacing.spacing16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isReady ? Colors.fillBrand : Colors.backgroundDefault)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
            .shadow(color: Colors.shadowMedium, radius: 16, x: 0, y: 8)
            // 단계가 바뀔 때 배경·글자색·게이지가 한 번에 툭 끊기지 않고 같이 부드럽게 전환되도록.
            .animation(.easeInOut(duration: 0.45), value: order.stage)
        }
        .buttonStyle(.plain)
    }

    private var titleText: String {
        switch order.stage {
        case .confirming: "주문 확인 중이에요"
        case .making: "음료를 만들고 있어요"
        case .readyForPickup: "음료가 준비됐어요"
        }
    }

    private var subtitleText: String {
        switch order.stage {
        case .confirming, .making:
            "\(order.storeName) · 내 앞에 \(order.queueCount)건"
        case .readyForPickup:
            order.pickupDeadlineText
        }
    }

    private var topRow: some View {
        HStack(spacing: Spacing.spacing12) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(isReady ? Colors.backgroundDefault : Colors.fillBrandWeak)
                Text("\(order.pickupNumber)")
                    .typography(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textBrand)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 0) {
                Text(titleText)
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(isReady ? Colors.textOnFill : Colors.textPrimary)
                Text(subtitleText)
                    .typography(Typography.bodySmRegular)
                    .foregroundStyle(isReady ? Colors.textOnFill.opacity(0.85) : Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(.chevronRight)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(isReady ? Colors.textOnFill : Colors.textTertiary)
        }
    }

    private var stepsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            HStack(spacing: 4) {
                segment(stepIndex: 0, corners: .leading)
                segment(stepIndex: 1, corners: .none)
                segment(stepIndex: 2, corners: .trailing)
            }

            HStack(spacing: Spacing.spacing8) {
                stepLabel("주문 확인", stepIndex: 0)
                stepLabel("만드는 중", stepIndex: 1)
                stepLabel("픽업 대기", stepIndex: 2)
            }
        }
    }

    private enum SegmentCorners { case leading, trailing, none }

    private func segment(stepIndex: Int, corners: SegmentCorners) -> some View {
        let isFilled = isReady || stepIndex <= order.stage.rawValue
        let fillColor = isReady ? Colors.backgroundDefault : Colors.fillBrand
        let trackColor = isReady ? Colors.backgroundDefault.opacity(0.3) : Colors.fillNeutralWeak
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: corners == .leading ? Radius.full : 0,
            bottomLeadingRadius: corners == .leading ? Radius.full : 0,
            bottomTrailingRadius: corners == .trailing ? Radius.full : 0,
            topTrailingRadius: corners == .trailing ? Radius.full : 0
        )

        return shape
            .fill(trackColor)
            .overlay(alignment: .leading) {
                shape
                    .fill(fillColor)
                    .scaleEffect(x: isFilled ? 1 : 0, anchor: .leading)
            }
            .frame(height: 8)
            .frame(maxWidth: .infinity)
    }

    private func stepLabel(_ title: String, stepIndex: Int) -> some View {
        let isActive = stepIndex == order.stage.rawValue
        let color: Color = if isReady {
            isActive ? Colors.textOnFill : Colors.textOnFill.opacity(0.7)
        } else {
            isActive ? Colors.textBrand : Colors.textTertiary
        }

        return Text(title)
            .typography(isActive ? Typography.bodyXsSemibold : Typography.bodyXsMedium)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: Spacing.spacing24) {
        LiveOrderBarView(
            order: LiveOrder(pickupNumber: 27, storeName: "범석관 카페", stage: .confirming, queueCount: 3, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderBarView(
            order: LiveOrder(pickupNumber: 27, storeName: "범석관 카페", stage: .making, queueCount: 2, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderBarView(
            order: LiveOrder(pickupNumber: 27, storeName: "범석관 카페", stage: .readyForPickup, queueCount: 0, pickupDeadlineText: "13:30까지 받아주세요"),
            action: {}
        )
    }
    .padding()
    .background(Colors.backgroundLower)
}
