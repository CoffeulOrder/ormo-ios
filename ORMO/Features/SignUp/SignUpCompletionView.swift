import SwiftUI

// Figma Base/Blue 팔레트 색 (축하 모션 컨페티 전용, DesignSystem 시맨틱 토큰에는 없음)
private let confettiBlue200 = Color(red: Double(0x91) / 255, green: Double(0xC6) / 255, blue: Double(0xFF) / 255)
private let confettiBlue300 = Color(red: Double(0x67) / 255, green: Double(0xAF) / 255, blue: Double(0xFE) / 255)
private let confettiBlue700 = Color(red: Double(0x00) / 255, green: Double(0x6B) / 255, blue: Double(0xDF) / 255)

// (value, duration): duration은 이전 구간 끝 시점부터 이 값에 도달하기까지 걸리는 시간(초)이다.
private struct Seg {
    let value: Double
    let duration: Double
}

private struct ConfettiSpec {
    enum Kind { case drop, dot, pill }
    let kind: Kind
    let restX: CGFloat // 착지 위치(화면 너비 대비 비율)
    let restY: CGFloat // 착지 위치(화면 높이 대비 비율)
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let rotate: [Seg] // degrees
    let scale: [Seg]
    let translateX: [Seg] // px, 착지 위치 기준 상대 오프셋
    let translateY: [Seg]
    let opacity: [Seg]
}

// Figma get_motion_context(노드 214:3923~214:3938)의 @keyframes 퍼센트·값을 2.2초 타임라인 기준 초 단위로 그대로 환산한 값이다.
// 터지며 날아와(translate) 착지한 뒤 관성으로 더 흘러가다(두 번째 translate 구간) 서서히 사라진다(opacity).
private let confettiSpecs: [ConfettiSpec] = [
    ConfettiSpec(
        kind: .drop, restX: 0.2438, restY: 0.285, width: 14.851, height: 14.851, color: confettiBlue300,
        rotate: [Seg(value: 0.0, duration: 0.5), Seg(value: 120.0, duration: 1.6), Seg(value: 120.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.5), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.4)],
        translateX: [Seg(value: 99.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: -8.0, duration: 1.15), Seg(value: -8.0, duration: 0.1)],
        translateY: [Seg(value: 12.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 50.0, duration: 1.15), Seg(value: 50.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.5), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.92), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .dot, restX: 0.147, restY: 0.2342, width: 8.274, height: 8.274, color: confettiBlue700,
        rotate: [Seg(value: 0.0, duration: 0.525), Seg(value: -161.0, duration: 1.575), Seg(value: -161.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.525), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.375)],
        translateX: [Seg(value: 132.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 4.0, duration: 1.125), Seg(value: 4.0, duration: 0.1)],
        translateY: [Seg(value: 52.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 63.0, duration: 1.125), Seg(value: 63.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.525), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.895), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .pill, restX: 0.2644, restY: 0.2162, width: 12.302, height: 13.092, color: confettiBlue200,
        rotate: [Seg(value: 0.0, duration: 0.55), Seg(value: 202.0, duration: 1.55), Seg(value: 202.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.55), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.35)],
        translateX: [Seg(value: 92.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: -1.0, duration: 1.1), Seg(value: -1.0, duration: 0.1)],
        translateY: [Seg(value: 67.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: 76.0, duration: 1.1), Seg(value: 76.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.55), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.87), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .drop, restX: 0.1789, restY: 0.1767, width: 10.194, height: 12.889, color: Colors.fillBrand,
        rotate: [Seg(value: 0.0, duration: 0.575), Seg(value: -123.0, duration: 1.525), Seg(value: -123.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.575), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.325)],
        translateX: [Seg(value: 121.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: -6.0, duration: 1.075), Seg(value: -6.0, duration: 0.1)],
        translateY: [Seg(value: 99.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 59.0, duration: 1.075), Seg(value: 59.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.575), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.845), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .dot, restX: 0.3029, restY: 0.1732, width: 11.204, height: 11.204, color: confettiBlue200,
        rotate: [Seg(value: 0.0, duration: 0.5), Seg(value: 164.0, duration: 1.6), Seg(value: 164.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.5), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.4)],
        translateX: [Seg(value: 76.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 6.0, duration: 1.15), Seg(value: 6.0, duration: 0.1)],
        translateY: [Seg(value: 103.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 72.0, duration: 1.15), Seg(value: 72.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.5), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.92), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .pill, restX: 0.4042, restY: 0.1845, width: 7.181, height: 13.671, color: confettiBlue300,
        rotate: [Seg(value: 0.0, duration: 0.525), Seg(value: -205.0, duration: 1.575), Seg(value: -205.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.525), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.375)],
        translateX: [Seg(value: 37.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 1.0, duration: 1.125), Seg(value: 1.0, duration: 0.1)],
        translateY: [Seg(value: 93.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 55.0, duration: 1.125), Seg(value: 55.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.525), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.895), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .drop, restX: 0.3868, restY: 0.1336, width: 14.081, height: 14.972, color: confettiBlue300,
        rotate: [Seg(value: 0.0, duration: 0.55), Seg(value: 126.0, duration: 1.55), Seg(value: 126.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.55), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.35)],
        translateX: [Seg(value: 45.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: -4.0, duration: 1.1), Seg(value: -4.0, duration: 0.1)],
        translateY: [Seg(value: 135.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: 68.0, duration: 1.1), Seg(value: 68.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.55), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.87), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .dot, restX: 0.4796, restY: 0.1587, width: 9.698, height: 9.698, color: confettiBlue700,
        rotate: [Seg(value: 0.0, duration: 0.575), Seg(value: -167.0, duration: 1.525), Seg(value: -167.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.575), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.325)],
        translateX: [Seg(value: 8.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 8.0, duration: 1.075), Seg(value: 8.0, duration: 0.1)],
        translateY: [Seg(value: 114.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 51.0, duration: 1.075), Seg(value: 51.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.575), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.845), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .pill, restX: 0.5822, restY: 0.1095, width: 10.676, height: 13.794, color: Colors.fillBrand,
        rotate: [Seg(value: 0.0, duration: 0.5), Seg(value: 208.0, duration: 1.6), Seg(value: 208.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.5), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.4)],
        translateX: [Seg(value: -28.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 3.0, duration: 1.15), Seg(value: 3.0, duration: 0.1)],
        translateY: [Seg(value: 154.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 64.0, duration: 1.15), Seg(value: 64.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.5), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.92), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .drop, restX: 0.5843, restY: 0.1467, width: 12.26, height: 14.204, color: Colors.fillBrand,
        rotate: [Seg(value: 0.0, duration: 0.525), Seg(value: -129.0, duration: 1.575), Seg(value: -129.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.525), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.375)],
        translateX: [Seg(value: -30.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: -2.0, duration: 1.125), Seg(value: -2.0, duration: 0.1)],
        translateY: [Seg(value: 124.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 77.0, duration: 1.125), Seg(value: 77.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.525), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.895), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .dot, restX: 0.6275, restY: 0.1913, width: 10.631, height: 10.631, color: confettiBlue200,
        rotate: [Seg(value: 0.0, duration: 0.55), Seg(value: 170.0, duration: 1.55), Seg(value: 170.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.55), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.35)],
        translateX: [Seg(value: -47.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: -7.0, duration: 1.1), Seg(value: -7.0, duration: 0.1)],
        translateY: [Seg(value: 88.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: 60.0, duration: 1.1), Seg(value: 60.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.55), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.87), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .pill, restX: 0.7033, restY: 0.149, width: 9.506, height: 13.926, color: confettiBlue700,
        rotate: [Seg(value: 0.0, duration: 0.575), Seg(value: -211.0, duration: 1.525), Seg(value: -211.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.575), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.325)],
        translateX: [Seg(value: -74.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 5.0, duration: 1.075), Seg(value: 5.0, duration: 0.1)],
        translateY: [Seg(value: 121.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 73.0, duration: 1.075), Seg(value: 73.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.575), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.845), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .drop, restX: 0.7236, restY: 0.2022, width: 12.696, height: 14.438, color: confettiBlue300,
        rotate: [Seg(value: 0.0, duration: 0.5), Seg(value: 132.0, duration: 1.6), Seg(value: 132.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.5), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.4)],
        translateX: [Seg(value: -82.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 0.0, duration: 1.25)],
        translateY: [Seg(value: 79.0, duration: 0.5), Seg(value: 0.0, duration: 0.45), Seg(value: 56.0, duration: 1.15), Seg(value: 56.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.5), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.92), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .dot, restX: 0.8649, restY: 0.2036, width: 10.697, height: 10.697, color: confettiBlue700,
        rotate: [Seg(value: 0.0, duration: 0.525), Seg(value: -173.0, duration: 1.575), Seg(value: -173.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.525), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.375)],
        translateX: [Seg(value: -135.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: -5.0, duration: 1.125), Seg(value: -5.0, duration: 0.1)],
        translateY: [Seg(value: 78.0, duration: 0.525), Seg(value: 0.0, duration: 0.45), Seg(value: 69.0, duration: 1.125), Seg(value: 69.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.525), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.895), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .pill, restX: 0.8114, restY: 0.229, width: 8.582, height: 13.894, color: confettiBlue200,
        rotate: [Seg(value: 0.0, duration: 0.55), Seg(value: 214.0, duration: 1.55), Seg(value: 214.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.55), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.35)],
        translateX: [Seg(value: -115.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: 7.0, duration: 1.1), Seg(value: 7.0, duration: 0.1)],
        translateY: [Seg(value: 57.0, duration: 0.55), Seg(value: 0.0, duration: 0.45), Seg(value: 52.0, duration: 1.1), Seg(value: 52.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.55), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.87), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    ),
    ConfettiSpec(
        kind: .drop, restX: 0.7677, restY: 0.274, width: 13.791, height: 14.899, color: Colors.fillBrand,
        rotate: [Seg(value: 0.0, duration: 0.575), Seg(value: -135.0, duration: 1.525), Seg(value: -135.0, duration: 0.1)],
        scale: [Seg(value: 0.2, duration: 0.575), Seg(value: 1.0, duration: 0.3), Seg(value: 1.0, duration: 1.325)],
        translateX: [Seg(value: -98.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 2.0, duration: 1.075), Seg(value: 2.0, duration: 0.1)],
        translateY: [Seg(value: 21.0, duration: 0.575), Seg(value: 0.0, duration: 0.45), Seg(value: 65.0, duration: 1.075), Seg(value: 65.0, duration: 0.1)],
        opacity: [Seg(value: 0.0, duration: 0.575), Seg(value: 1.0, duration: 0.08), Seg(value: 1.0, duration: 0.845), Seg(value: 0.0, duration: 0.6), Seg(value: 0.0, duration: 0.1)]
    )
]

private struct ConfettiAnimatedValues {
    var scale: Double
    var rotate: Double
    var translateX: Double
    var translateY: Double
    var opacity: Double
}

private struct ConfettiPieceView: View {
    let spec: ConfettiSpec
    @State private var trigger = false

    private var initialValue: ConfettiAnimatedValues {
        ConfettiAnimatedValues(
            scale: spec.scale.first?.value ?? 0.2,
            rotate: 0,
            translateX: spec.translateX.first?.value ?? 0,
            translateY: spec.translateY.first?.value ?? 0,
            opacity: 0
        )
    }

    var body: some View {
        content
            .keyframeAnimator(initialValue: initialValue, trigger: trigger) { content, value in
                content
                    .scaleEffect(value.scale)
                    .rotationEffect(.degrees(value.rotate))
                    .offset(x: value.translateX, y: value.translateY)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    for seg in spec.scale {
                        CubicKeyframe(seg.value, duration: seg.duration)
                    }
                }
                KeyframeTrack(\.rotate) {
                    for seg in spec.rotate {
                        CubicKeyframe(seg.value, duration: seg.duration)
                    }
                }
                KeyframeTrack(\.translateX) {
                    for seg in spec.translateX {
                        CubicKeyframe(seg.value, duration: seg.duration)
                    }
                }
                KeyframeTrack(\.translateY) {
                    for seg in spec.translateY {
                        CubicKeyframe(seg.value, duration: seg.duration)
                    }
                }
                KeyframeTrack(\.opacity) {
                    for seg in spec.opacity {
                        CubicKeyframe(seg.value, duration: seg.duration)
                    }
                }
            }
            .onAppear {
                trigger.toggle()
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
                .frame(width: 5, height: 13)
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
                ForEach(Array(confettiSpecs.enumerated()), id: \.offset) { _, spec in
                    ConfettiPieceView(spec: spec)
                        .position(x: proxy.size.width * spec.restX, y: proxy.size.height * spec.restY)
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
        Text("\(viewModel.name)님!\nORMO로 어서와요!")
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
