import SwiftUI
import Lottie

struct SignUpCompletionView: View {
    @State private var viewModel: SignUpCompletionViewModel
    private let onFinished: () -> Void

    @State private var titleOffsetY: CGFloat = 12
    @State private var titleOpacity: Double = 0

    init(name: String, onFinished: @escaping () -> Void) {
        _viewModel = State(initialValue: SignUpCompletionViewModel(name: name))
        self.onFinished = onFinished
    }

    var body: some View {
        GeometryReader { proxy in
            // Lottie 원본 캔버스가 375×812라서, 너비 기준으로 같은 비율로 스케일한다.
            let scale = proxy.size.width / 375
            let lottieHeight = 812 * scale
            // 컵 심볼 프레임(중심 29.8%, 높이 128)도 같은 비율로 스케일해 하단 좌표를 구한다.
            let cupBottomY = lottieHeight * 0.298 + 64 * scale

            ZStack(alignment: .top) {
                LottieView(animation: .named("ormo-cup-confetti"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .resizable()
                    .frame(width: proxy.size.width, height: lottieHeight)

                titleView
                    .frame(maxWidth: .infinity)
                    .padding(.top, cupBottomY + 32)
                    .offset(y: titleOffsetY)
                    .opacity(titleOpacity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear(perform: playMotion)
    }

    private var titleView: some View {
        Text("\(viewModel.name)님!\nORMO로 어서와요!")
            .typography(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .multilineTextAlignment(.center)
    }

    // Figma smart-animate 타임라인(2.2초): 심볼·컨페티는 Lottie가 재생하고, 제목은 0.9~1.3초에 등장한다.
    // 버튼 없이 2.8초가 지나면 자동으로 다음 화면(1.1.1 매장 선택)으로 넘어간다.
    private func playMotion() {
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            titleOffsetY = 0
            titleOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            onFinished()
        }
    }
}

#Preview {
    SignUpCompletionView(name: "오르모", onFinished: {})
}
