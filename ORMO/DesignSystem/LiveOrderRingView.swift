import SwiftUI

// 원형 진행 고리(헤더 압축 상태에서 쓰는 작은 현황 표시). 12시부터 시계 방향으로 차오르고
// 끝은 둥글게: 주문 확인 중 1/3 · 만드는 중 2/3 · 픽업 대기면 꽉 참.
struct LiveOrderRingView: View {
    let pickupNumber: Int
    let stage: OrderStage
    var size: CGFloat = 32

    private var progress: CGFloat {
        CGFloat(stage.rawValue + 1) / 3
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Colors.fillNeutralWeak, lineWidth: size * 3.4 / 32)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Colors.fillBrand, style: StrokeStyle(lineWidth: size * 3.4 / 32, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.45), value: progress)
            Text("\(pickupNumber)")
                .typography(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textBrand)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: Spacing.spacing24) {
        LiveOrderRingView(pickupNumber: 27, stage: .confirming)
        LiveOrderRingView(pickupNumber: 27, stage: .making)
        LiveOrderRingView(pickupNumber: 27, stage: .readyForPickup)
    }
    .padding()
}
