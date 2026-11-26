import SwiftUI

// Live Order Bar(Flat) — 메뉴 홈 맨 위, 헤더 바로 아래 떠 있던 자리를 대신해 스크롤 콘텐츠
// 맨 위에 자리 잡는 실시간 주문 현황. 카드·그림자 없이 배경에 바로 얹힌다(전체가 버튼).
// 끝까지 내리면 이 영역은 사라지고 헤더의 매장 이름 자리에 LiveOrderHeaderView가 대신 뜬다.
struct LiveOrderBarView: View {
    let order: LiveOrder
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.spacing20) {
                row
                stepsView
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.45), value: order.stage)
    }

    private var row: some View {
        HStack(spacing: Spacing.spacing16) {
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                titleText
                    .typography(Typography.bodyLgSemibold)
                Text(subtitleText)
                    .typography(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // 글자 영역은 오른쪽에 80pt를 비워 둔다(일러스트 72 + 간격 8).
        .padding(.trailing, 80)
        .overlay(alignment: .trailing) {
            // 디자인 상자(72)보다 12pt 더 큰 96 뷰라, 오른쪽으로 12pt 더 밀어야
            // 96 뷰의 가운데가 72 상자의 가운데(= 오른쪽 내용 끝)와 맞는다.
            LiveOrderIllustrationView(stage: order.stage)
                .offset(x: 12)
        }
    }

    private var titleText: Text {
        Text("\(order.pickupNumber)번").foregroundStyle(Colors.textBrand)
            + Text(" \(titleSuffix)").foregroundStyle(Colors.textPrimary)
    }

    private var titleSuffix: String {
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

    private var stepsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            HStack(spacing: 4) {
                segment(stepIndex: 0, corners: .leading)
                segment(stepIndex: 1, corners: .none)
                segment(stepIndex: 2, corners: .trailing)
            }
            .frame(height: 8)

            HStack(spacing: Spacing.spacing8) {
                stepLabel("주문 확인", stepIndex: 0)
                stepLabel("만드는 중", stepIndex: 1)
                stepLabel("픽업 대기", stepIndex: 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum SegmentCorners { case leading, trailing, none }

    private func segment(stepIndex: Int, corners: SegmentCorners) -> some View {
        let isFilled = stepIndex <= order.stage.rawValue
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: corners == .leading ? Radius.full : 0,
            bottomLeadingRadius: corners == .leading ? Radius.full : 0,
            bottomTrailingRadius: corners == .trailing ? Radius.full : 0,
            topTrailingRadius: corners == .trailing ? Radius.full : 0
        )

        return shape
            .fill(isFilled ? Colors.fillBrand : Colors.fillNeutralWeak)
            .frame(maxWidth: .infinity)
    }

    private func stepLabel(_ title: String, stepIndex: Int) -> some View {
        let isActive = stepIndex == order.stage.rawValue
        return Text(title)
            .typography(isActive ? Typography.bodySmSemibold : Typography.bodySmMedium)
            .foregroundStyle(isActive ? Colors.textBrand : Colors.textTertiary)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: Spacing.spacing24) {
        LiveOrderBarView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .confirming, queueCount: 3, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderBarView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .making, queueCount: 2, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderBarView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .readyForPickup, queueCount: 0, pickupDeadlineText: "13:30까지 받아주세요"),
            action: {}
        )
    }
    .padding()
    .background(
        LinearGradient(colors: [Colors.backgroundDefault, Colors.baseBlue50], startPoint: .top, endPoint: .bottom)
    )
}
