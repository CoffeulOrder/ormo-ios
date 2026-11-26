import SwiftUI
import Lottie

// 실시간 주문 현황 일러스트. 디자인 상자는 72×72지만, 커피 방울·김이 상자 위로 살짝
// 넘치도록 그려져 있어 Lottie 뷰 자체는 사방 12pt 더 큰 96×96으로 받아 가운데 맞춘다.
// 화면에 보이는 동안 2초 주기로 반복 재생하고, 상태가 바뀌면 처음부터 다시 재생한다
// (동작 줄이기 켜짐이면 애니메이션 대신 정지 그림 한 장).
struct LiveOrderIllustrationView: View {
    let stage: OrderStage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var lottieName: String {
        switch stage {
        case .confirming: "live-order-checking"
        case .making: "live-order-making"
        case .readyForPickup: "live-order-ready"
        }
    }

    private var stillImage: ImageResource {
        switch stage {
        case .confirming: .liveOrderCheckingStill
        case .making: .liveOrderMakingStill
        case .readyForPickup: .liveOrderReadyStill
        }
    }

    var body: some View {
        Group {
            if reduceMotion {
                Image(stillImage)
                    .resizable()
                    .scaledToFit()
            } else {
                LottieView(animation: .named(lottieName))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                    .resizable()
                    // 상태가 바뀌면 같은 자리에서 이어 그리지 않고 완전히 새로 시작하도록
                    // 뷰 자체의 정체성을 바꾼다("상태가 바뀌면 해당 상태 파일로 바꿔 처음부터").
                    .id(lottieName)
            }
        }
        .frame(width: 96, height: 96)
        // 꾸밈 요소라 스크린 리더에서는 숨긴다 — 상태는 옆 글자가 이미 알려준다.
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: Spacing.spacing24) {
        LiveOrderIllustrationView(stage: .confirming)
        LiveOrderIllustrationView(stage: .making)
        LiveOrderIllustrationView(stage: .readyForPickup)
    }
    .padding()
}
