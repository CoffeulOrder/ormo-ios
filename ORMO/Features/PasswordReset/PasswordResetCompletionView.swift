import SwiftUI

struct PasswordResetCompletionView: View {
    let onLoginTapped: () -> Void

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            symbolView
                .padding(.bottom, Spacing.spacing40)

            stackView

            Spacer()

            bottomCTA
        }
        .frame(maxWidth: .infinity)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { hasAppeared = true }
    }

    private struct SymbolMotion {
        var symbolTranslateY: CGFloat = 349
        var cupScaleX: CGFloat = 1
        var cupScaleY: CGFloat = 1
        var steamLTranslateY: CGFloat = 13.1552734375
        var steamRTranslateY: CGFloat = 1.5703125
        var badgeRotationDegrees: Double = -30
        var badgeScale: CGFloat = 0
        var badgeOpacity: Double = 0
    }

    private struct FadeUpMotion {
        var translateY: CGFloat
        var opacity: Double
    }

    private static let easeOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )
    private static let easeInOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.42, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )
    // 스팀이 안착하며 살짝 튕기는 구간(피그마 anticipation 커브)
    private static let overshootCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.45, y: 1.45),
        endControlPoint: UnitPoint(x: 0.8, y: 1)
    )

    // Figma "ORMO Symbol" 좌표(컵 97.41×86.11, 스팀 L/R, 배지 36×36)를 100.54×128 기준 박스에 그대로 배치한다.
    // 모션은 피그마 smart-animate 타임라인(2초)을 그대로 옮긴 것: 심볼이 아래에서 튀어 오르며 안착하고,
    // 컵은 안착 충격으로 짧게 찌그러졌다 펴지고, 스팀은 한 번 솟았다 가라앉고, 배지는 회전하며 팝인한다.
    private var symbolView: some View {
        Color.clear
            .frame(width: 100.54, height: 128)
            .keyframeAnimator(initialValue: SymbolMotion(), trigger: hasAppeared) { _, motion in
                ZStack(alignment: .topLeading) {
                    Image(.ormoCup)
                        .resizable()
                        .frame(width: 97.41, height: 86.11)
                        .scaleEffect(x: motion.cupScaleX, y: motion.cupScaleY)
                        .offset(x: 1.55, y: 40.35)

                    Image(.ormoSteamL)
                        .resizable()
                        .frame(width: 19.97, height: 26.7)
                        .offset(x: 35.47, y: motion.steamLTranslateY)

                    Image(.ormoSteamR)
                        .resizable()
                        .frame(width: 26.17, height: 36.59)
                        .offset(x: 57.49, y: motion.steamRTranslateY)

                    Circle()
                        .fill(Colors.fillSuccess)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .overlay(
                            Image(.badgeCheckIcon)
                                .resizable()
                                .frame(width: 20, height: 20)
                        )
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(motion.badgeRotationDegrees))
                        .scaleEffect(motion.badgeScale)
                        .opacity(motion.badgeOpacity)
                        .offset(x: 62, y: 92)
                }
                .frame(width: 100.54, height: 128, alignment: .topLeading)
                .offset(y: motion.symbolTranslateY - 233)
            } keyframes: { _ in
                KeyframeTrack(\.symbolTranslateY) {
                    LinearKeyframe(349, duration: 0.15)
                    LinearKeyframe(225, duration: 0.35, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(233, duration: 0.25, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(233, duration: 1.25)
                }
                KeyframeTrack(\.cupScaleX) {
                    LinearKeyframe(1.06, duration: 0.15, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(0.96, duration: 0.25, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 0.25, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 1.35)
                }
                KeyframeTrack(\.cupScaleY) {
                    LinearKeyframe(0.9, duration: 0.15, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1.05, duration: 0.25, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 0.25, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 1.35)
                }
                KeyframeTrack(\.steamLTranslateY) {
                    LinearKeyframe(13.1552734375, duration: 0.1)
                    LinearKeyframe(1.1552734375, duration: 0.35, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(13.1552734375, duration: 0.35, timingCurve: Self.overshootCurve)
                    LinearKeyframe(13.1552734375, duration: 1.2)
                }
                KeyframeTrack(\.steamRTranslateY) {
                    LinearKeyframe(1.5703125, duration: 0.15)
                    LinearKeyframe(-14.4296875, duration: 0.35, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1.5703125, duration: 0.35, timingCurve: Self.overshootCurve)
                    LinearKeyframe(1.5703125, duration: 1.15)
                }
                KeyframeTrack(\.badgeRotationDegrees) {
                    LinearKeyframe(-30, duration: 0.55)
                    LinearKeyframe(0, duration: 0.25, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(0, duration: 1.2)
                }
                KeyframeTrack(\.badgeScale) {
                    LinearKeyframe(0, duration: 0.55)
                    LinearKeyframe(1.15, duration: 0.25, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 1.05)
                }
                KeyframeTrack(\.badgeOpacity) {
                    LinearKeyframe(0, duration: 0.55)
                    LinearKeyframe(1, duration: 0.1, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 1.35)
                }
            }
    }

    private var stackView: some View {
        VStack(spacing: Spacing.spacing12) {
            Text("비밀번호를 변경했어요")
                .typography(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)

            Text("새 비밀번호로 로그인해주세요")
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 422, opacity: 0), trigger: hasAppeared) { content, motion in
            content
                .offset(y: motion.translateY - 406)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(422, duration: 0.72)
                LinearKeyframe(406, duration: 0.35, timingCurve: Self.easeOutCurve)
                LinearKeyframe(406, duration: 0.93)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.72)
                LinearKeyframe(1, duration: 0.35, timingCurve: Self.easeOutCurve)
                LinearKeyframe(1, duration: 0.93)
            }
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            Button(action: onLoginTapped) {
                Text("로그인하기")
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 716, opacity: 0), trigger: hasAppeared) { content, motion in
            content
                .offset(y: motion.translateY - 684)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(716, duration: 0.85)
                LinearKeyframe(684, duration: 0.35, timingCurve: Self.easeOutCurve)
                LinearKeyframe(684, duration: 0.8)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.85)
                LinearKeyframe(1, duration: 0.35, timingCurve: Self.easeOutCurve)
                LinearKeyframe(1, duration: 0.8)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    PasswordResetCompletionView(onLoginTapped: {})
}
