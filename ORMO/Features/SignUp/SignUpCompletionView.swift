import SwiftUI

// Figma Base/Blue 팔레트 색 (축하 모션 컨페티 전용, DesignSystem 시맨틱 토큰에는 없음)
private let confettiBlue200 = Color(red: Double(0x91) / 255, green: Double(0xC6) / 255, blue: Double(0xFF) / 255)
private let confettiBlue300 = Color(red: Double(0x67) / 255, green: Double(0xAF) / 255, blue: Double(0xFE) / 255)
private let confettiBlue700 = Color(red: Double(0x00) / 255, green: Double(0x6B) / 255, blue: Double(0xDF) / 255)

private struct ConfettiSpec {
    enum Kind { case drop, dot, pill }
    let kind: Kind
    let x: CGFloat // 화면 너비 대비 비율
    let y: CGFloat // 화면 높이 대비 비율
    let width: CGFloat
    let height: CGFloat
    let rotation: Double
    let color: Color
}

// 좌표·크기·회전각은 Figma 노드(214:3923~214:3938)의 절대값을 375×812 기준 비율로 환산한 값이다.
private let confettiSpecs: [ConfettiSpec] = [
    ConfettiSpec(kind: .drop, x: 0.2438, y: 0.2850, width: 14.9, height: 14.9, rotation: -20, color: confettiBlue300),
    ConfettiSpec(kind: .dot, x: 0.1470, y: 0.2342, width: 8.3, height: 8.3, rotation: 0, color: confettiBlue700),
    ConfettiSpec(kind: .pill, x: 0.2644, y: 0.2162, width: 5, height: 13.1, rotation: 41, color: confettiBlue200),
    ConfettiSpec(kind: .drop, x: 0.1789, y: 0.1766, width: 10.2, height: 12.9, rotation: 15, color: Colors.fillBrand),
    ConfettiSpec(kind: .dot, x: 0.3029, y: 0.1732, width: 11.2, height: 11.2, rotation: 0, color: confettiBlue200),
    ConfettiSpec(kind: .pill, x: 0.4043, y: 0.1845, width: 5, height: 13.7, rotation: -10, color: confettiBlue300),
    ConfettiSpec(kind: .drop, x: 0.3868, y: 0.1336, width: 14.1, height: 15.0, rotation: -30, color: confettiBlue700),
    ConfettiSpec(kind: .dot, x: 0.4796, y: 0.1587, width: 9.7, height: 9.7, rotation: 0, color: Colors.fillBrand),
    ConfettiSpec(kind: .pill, x: 0.5822, y: 0.1095, width: 5, height: 13.8, rotation: 29, color: Colors.fillBrand),
    ConfettiSpec(kind: .drop, x: 0.5843, y: 0.1467, width: 12.3, height: 14.2, rotation: 25, color: confettiBlue200),
    ConfettiSpec(kind: .dot, x: 0.6275, y: 0.1913, width: 10.6, height: 10.6, rotation: 0, color: confettiBlue300),
    ConfettiSpec(kind: .pill, x: 0.7033, y: 0.1489, width: 5, height: 13.9, rotation: -22, color: confettiBlue700),
    ConfettiSpec(kind: .drop, x: 0.7236, y: 0.2023, width: 12.7, height: 14.4, rotation: -15, color: confettiBlue700),
    ConfettiSpec(kind: .dot, x: 0.8649, y: 0.2037, width: 10.7, height: 10.7, rotation: 0, color: Colors.fillBrand),
    ConfettiSpec(kind: .pill, x: 0.8114, y: 0.2290, width: 5, height: 13.9, rotation: 17, color: confettiBlue200),
    ConfettiSpec(kind: .drop, x: 0.7677, y: 0.2740, width: 13.8, height: 14.9, rotation: 10, color: confettiBlue300)
]

private struct ConfettiPieceView: View {
    let spec: ConfettiSpec
    let index: Int

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.2
    @State private var riseOffset: CGFloat = -16

    var body: some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(y: riseOffset)
            .onAppear {
                // Figma 2.2초 타임라인: 입자별로 살짝 엇갈려 터지고(burst), 1.5초 전후부터 사라진다.
                let burstDelay = 0.45 + Double(index % 6) * 0.02
                let fadeDelay = 1.45 + Double(index % 6) * 0.02
                withAnimation(.easeOut(duration: 0.35).delay(burstDelay)) {
                    opacity = 1
                    scale = 1
                    riseOffset = 0
                }
                withAnimation(.easeIn(duration: 0.6).delay(fadeDelay)) {
                    opacity = 0
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch spec.kind {
        case .drop:
            Image(.confettiDrop)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: spec.width, height: spec.height)
                .foregroundStyle(spec.color)
                .rotationEffect(.degrees(spec.rotation))
        case .dot:
            Image(.confettiDot)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: spec.width, height: spec.height)
                .foregroundStyle(spec.color)
        case .pill:
            Capsule()
                .fill(spec.color)
                .frame(width: spec.width, height: spec.height)
                .rotationEffect(.degrees(spec.rotation))
        }
    }
}

private struct CupBounce {
    var scaleX = 1.0
    var scaleY = 1.0
}

private struct SteamPop {
    var scale: CGFloat = 0
    var riseOffset: CGFloat = 18
}

struct SignUpCompletionView: View {
    @State private var viewModel: SignUpCompletionViewModel
    private let onFinished: () -> Void

    @State private var symbolOffsetY: CGFloat = -48
    @State private var symbolOpacity: Double = 0
    @State private var cupBounceTrigger = false

    @State private var steamLOpacity: Double = 0
    @State private var steamLPopTrigger = false
    @State private var steamLSway: Double = 0

    @State private var steamROpacity: Double = 0
    @State private var steamRPopTrigger = false
    @State private var steamRSway: Double = 0

    @State private var titleOffsetY: CGFloat = 12
    @State private var titleOpacity: Double = 0

    init(name: String, onFinished: @escaping () -> Void) {
        _viewModel = State(initialValue: SignUpCompletionViewModel(name: name))
        self.onFinished = onFinished
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(confettiSpecs.enumerated()), id: \.offset) { index, spec in
                    ConfettiPieceView(spec: spec, index: index)
                        .position(x: proxy.size.width * spec.x, y: proxy.size.height * spec.y)
                }

                symbolView
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.298)
                    .offset(y: symbolOffsetY)
                    .opacity(symbolOpacity)

                titleView
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.456)
                    .offset(y: titleOffsetY)
                    .opacity(titleOpacity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear(perform: playMotion)
    }

    // ORMO Symbol 프레임(100.54×128) 안에서 Cup·Steam L·Steam R의 절대 위치는 Figma inset 값 그대로다.
    private var symbolView: some View {
        ZStack(alignment: .topLeading) {
            Image(.ormoSymbolCup)
                .resizable()
                .scaledToFit()
                .frame(width: 97.41, height: 86.11)
                .offset(x: 1.56, y: 40.33)
                .keyframeAnimator(initialValue: CupBounce(), trigger: cupBounceTrigger) { content, value in
                    content.scaleEffect(x: value.scaleX, y: value.scaleY)
                } keyframes: { _ in
                    KeyframeTrack(\.scaleX) {
                        CubicKeyframe(1.0, duration: 0)
                        CubicKeyframe(1.12, duration: 0.1)
                        CubicKeyframe(0.96, duration: 0.22)
                        CubicKeyframe(1.0, duration: 0.2)
                    }
                    KeyframeTrack(\.scaleY) {
                        CubicKeyframe(1.0, duration: 0)
                        CubicKeyframe(0.86, duration: 0.1)
                        CubicKeyframe(1.05, duration: 0.22)
                        CubicKeyframe(1.0, duration: 0.2)
                    }
                }

            Image(.ormoSymbolSteamL)
                .resizable()
                .scaledToFit()
                .frame(width: 19.97, height: 26.70)
                .offset(x: 35.47, y: 13.16)
                .opacity(steamLOpacity)
                .rotationEffect(.degrees(steamLSway))
                .keyframeAnimator(initialValue: SteamPop(), trigger: steamLPopTrigger) { content, value in
                    content.scaleEffect(value.scale).offset(y: value.riseOffset)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(0, duration: 0)
                        CubicKeyframe(1.2, duration: 0.25)
                        CubicKeyframe(1.0, duration: 0.15)
                    }
                    KeyframeTrack(\.riseOffset) {
                        CubicKeyframe(18, duration: 0)
                        CubicKeyframe(-6, duration: 0.25)
                        CubicKeyframe(0, duration: 0.15)
                    }
                }

            Image(.ormoSymbolSteamR)
                .resizable()
                .scaledToFit()
                .frame(width: 26.17, height: 36.58)
                .offset(x: 57.49, y: 1.57)
                .opacity(steamROpacity)
                .rotationEffect(.degrees(steamRSway))
                .keyframeAnimator(initialValue: SteamPop(), trigger: steamRPopTrigger) { content, value in
                    content.scaleEffect(value.scale).offset(y: value.riseOffset)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(0, duration: 0)
                        CubicKeyframe(1.2, duration: 0.25)
                        CubicKeyframe(1.0, duration: 0.15)
                    }
                    KeyframeTrack(\.riseOffset) {
                        CubicKeyframe(18, duration: 0)
                        CubicKeyframe(-6, duration: 0.25)
                        CubicKeyframe(0, duration: 0.15)
                    }
                }
        }
        .frame(width: 100.54, height: 128)
    }

    private var titleView: some View {
        Text("(\(viewModel.name))님!\nORMO로 어서와요!")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .multilineTextAlignment(.center)
    }

    // Figma smart-animate 타임라인(2.2초): 심볼 낙하 → 김·조각 터짐 → 제목 순서로 등장하고,
    // 버튼 없이 2.8초가 지나면 자동으로 다음 화면(1.1.1 매장 선택)으로 넘어간다.
    private func playMotion() {
        withAnimation(.easeOut(duration: 0.15)) {
            symbolOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.4)) {
            symbolOffsetY = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            cupBounceTrigger.toggle()
        }

        withAnimation(.easeOut(duration: 0.1).delay(0.55)) {
            steamLOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            steamLPopTrigger.toggle()
        }
        withAnimation(.easeInOut(duration: 0.4).delay(1.3)) {
            steamLSway = 6
        }
        withAnimation(.easeInOut(duration: 0.4).delay(1.7)) {
            steamLSway = 0
        }

        withAnimation(.easeOut(duration: 0.1).delay(0.63)) {
            steamROpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.63) {
            steamRPopTrigger.toggle()
        }
        withAnimation(.easeInOut(duration: 0.4).delay(1.38)) {
            steamRSway = -6
        }
        withAnimation(.easeInOut(duration: 0.4).delay(1.78)) {
            steamRSway = 0
        }

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
