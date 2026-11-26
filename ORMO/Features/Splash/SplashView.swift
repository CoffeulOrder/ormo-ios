import SwiftUI
import Lottie

struct SplashView: View {
    var onFinished: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme

    // ormo-logo-motion.json 원본 캔버스가 375×812, 60fps · 96프레임(1.6초)짜리 로고(컵+워드마크) 모션이다.
    // 다른 Lottie 화면들과 같은 규칙으로, 너비 비율로 스케일해 화면에 꽉 채우고 위쪽을 맞춘다.
    private static let duration: Double = 96.0 / 60.0

    // 다크모드에서는 워드마크(글자)만 흰색으로 바꾼 버전. 컵 색은 두 파일 모두 동일(Figma 브랜드 블루).
    private var animationName: String {
        colorScheme == .dark ? "ormo-logo-motion-dark" : "ormo-logo-motion"
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / 375

            LottieView(animation: .named(animationName))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .resizable()
                .frame(width: proxy.size.width, height: 812 * scale)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .task {
            try? await Task.sleep(for: .seconds(Self.duration))
            onFinished()
        }
    }
}

#Preview {
    SplashView()
}
