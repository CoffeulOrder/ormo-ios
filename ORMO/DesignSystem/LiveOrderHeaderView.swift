import SwiftUI

// Live Order Header — 메뉴 홈 헤더 현황. 맨 위 Live Order Bar(LiveOrderBarView)가 스크롤로
// 헤더 밑으로 들어가면, 매장 이름 자리에 이걸로 바뀌어 올라온다. 원형 고리(32, 가운데
// 픽업 번호) + 단계 글자 + 내 앞 n건. 픽업 대기면 고리 뒤로 물결(Halo)이 번진다.
// 진행 중인 주문이 2건 이상이면 대표 주문(가장 먼저 접수된 것) 하나만 보여주고, "내 앞 n건"
// 대신 "외 N건"으로 바꿔 나머지 건수를 알려준다 — 탭하면(action) 직접 상세로 가는 대신
// 헤더 아래 패널이 펼쳐진다(호출하는 쪽에서 action을 다르게 넘겨준다).
struct LiveOrderHeaderView: View {
    let order: LiveOrder
    var additionalCount: Int = 0
    let action: () -> Void

    private var isReady: Bool { order.stage == .readyForPickup }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing8) {
                ZStack {
                    if isReady {
                        LiveOrderHaloView()
                    }
                    LiveOrderRingView(pickupNumber: order.pickupNumber, stage: order.stage)
                }
                .frame(width: 32, height: 32)

                Text(stageText)
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textPrimary)

                Text(metaText)
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var stageText: String {
        switch order.stage {
        case .confirming: "주문 확인 중"
        case .making: "만드는 중"
        case .readyForPickup: "픽업 대기"
        }
    }

    private var metaText: String {
        guard additionalCount == 0 else { return "· 외 \(additionalCount)건" }
        return switch order.stage {
        case .confirming, .making: "· 내 앞 \(order.queueCount)건"
        case .readyForPickup: "· 받아 가세요"
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.spacing24) {
        LiveOrderHeaderView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .confirming, queueCount: 3, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderHeaderView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .making, queueCount: 2, pickupDeadlineText: ""),
            action: {}
        )
        LiveOrderHeaderView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .readyForPickup, queueCount: 0, pickupDeadlineText: "13:30까지 받아주세요"),
            action: {}
        )
        LiveOrderHeaderView(
            order: LiveOrder(orderId: 1, pickupNumber: 27, storeName: "범석관 카페", stage: .making, queueCount: 2, pickupDeadlineText: ""),
            additionalCount: 1,
            action: {}
        )
    }
    .padding()
}
