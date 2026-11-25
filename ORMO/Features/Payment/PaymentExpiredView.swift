import SwiftUI
import Lottie

struct PaymentExpiredView: View {
    @Environment(HomeRouter.self) private var router
    @State private var appeared = false

    private struct FadeUpMotion {
        var translateY: CGFloat
        var opacity: Double = 0
    }

    private static let easeOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            symbolView

            textStack
                .padding(.top, Spacing.spacing56)

            Spacer()

            bottomCTA
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { appeared = true }
    }

    // Lottie(ormo-cup-badge, 375×812 캔버스)에 "ORMO Symbol"이 Figma와 동일한 좌표(137,233, 100.54×128)로
    // 들어있다. 캔버스를 1:1 원본 크기로 그린 뒤 그 좌표만큼 당겨서 심볼 박스만 잘라 쓴다.
    private var symbolView: some View {
        Color.clear
            .frame(width: 100.54, height: 128)
            .overlay(alignment: .topLeading) {
                LottieView(animation: .named("ormo-cup-badge"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .resizable()
                    .frame(width: 375, height: 812)
                    .offset(x: -137, y: -233)
            }
            .clipped()
    }

    private var textStack: some View {
        VStack(spacing: Spacing.spacing12) {
            Text("결제 가능 시간이 지났어요")
                .typography(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)

            Group {
                Text("결제가 완료되지 않았어요")
                Text("장바구니에서 다시 주문해주세요")
            }
            .typography(Typography.bodyMdMedium)
            .foregroundStyle(Colors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 10), trigger: appeared) { content, motion in
            content
                .offset(y: motion.translateY)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(10, duration: 0.8)
                LinearKeyframe(0, duration: 0.4, timingCurve: Self.easeOutCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.8)
                LinearKeyframe(1, duration: 0.4, timingCurve: Self.easeOutCurve)
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

            Button(action: backToCartTapped) {
                Text("다시 주문하기")
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
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 32), trigger: appeared) { content, motion in
            content
                .offset(y: motion.translateY)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(32, duration: 1.0)
                LinearKeyframe(0, duration: 0.4, timingCurve: Self.easeOutCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 1.0)
                LinearKeyframe(1, duration: 0.4, timingCurve: Self.easeOutCurve)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // "... → 장바구니 → 결제 확인 중 → 주문 만료" 순서로 들어오므로 끝에서 2개만 지우면
    // 장바구니가 top이 된다. path를 통째로 새 값으로 바꾸면 NavigationStack 전환이 깨진다.
    private func backToCartTapped() {
        router.path.removeLast(2)
    }
}

#Preview {
    PaymentExpiredView()
        .environment(HomeRouter())
}
