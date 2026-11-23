import SwiftUI

// Figma "4.5.1 알림 권한 안내" — 네이티브 .sheet()가 아니라 Dim+Bottom Sheet를 직접 겹치는 커스텀 뷰다.
// 시트가 떠오른 뒤 종 아이콘이 톡 튀며 커지고(0.3초) 좌우로 한 번 흔들린다(0.6초).
struct NotificationPermissionSheet: View {
    let onSkip: () -> Void
    let onAllow: () -> Void

    @State private var appeared = false

    private struct DimMotion {
        var opacity: Double = 0
    }

    private struct SheetMotion {
        var translateY: CGFloat = 298
    }

    private struct BellTileMotion {
        var scale: CGFloat = 0.6
        var opacity: Double = 0
    }

    private struct BellShakeMotion {
        var rotationDegrees: Double = 0
    }

    private static let easeOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )
    private static let easeInOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.42, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )
    // 시트가 올라오는 스프링풍 커브(Figma cubic-bezier(0.2, 0.8, 0.2, 1))
    private static let sheetSpringCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.2, y: 0.8),
        endControlPoint: UnitPoint(x: 0.2, y: 1)
    )
    // 종 아이콘이 톡 튀는 오버슈트 커브(Figma cubic-bezier(0.45, 1.45, 0.8, 1))
    private static let bounceCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.45, y: 1.45),
        endControlPoint: UnitPoint(x: 0.8, y: 1)
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            dimView
            sheetView
        }
        .ignoresSafeArea()
        .onAppear { appeared = true }
    }

    private var dimView: some View {
        Colors.backgroundDim
            .keyframeAnimator(initialValue: DimMotion(), trigger: appeared) { content, motion in
                content.opacity(motion.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(1, duration: 0.2, timingCurve: Self.easeOutCurve)
                }
            }
    }

    private var sheetView: some View {
        VStack(spacing: 0) {
            handle
            header
            bellIcon
                .padding(.vertical, Spacing.spacing8)
            footer
        }
        .padding(.bottom, Spacing.spacing32)
        .frame(maxWidth: .infinity)
        .background(Colors.backgroundFloated)
        .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: Radius.sheet, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: Radius.sheet)
        )
        .shadow(color: Colors.shadowMedium, radius: 32, x: 0, y: 8)
        .keyframeAnimator(initialValue: SheetMotion(), trigger: appeared) { content, motion in
            content.offset(y: motion.translateY)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(298, duration: 0.25)
                LinearKeyframe(0, duration: 0.35, timingCurve: Self.sheetSpringCurve)
            }
        }
    }

    private var handle: some View {
        // Figma "base/grey/grey-300" — 핸들 전용 고정 색이라 디자인시스템 토큰으로 추상화하지 않았다.
        Capsule()
            .fill(Color(red: 209 / 255, green: 214 / 255, blue: 219 / 255))
            .frame(width: 40, height: 4)
            .padding(.vertical, Spacing.spacing4)
    }

    private var header: some View {
        VStack(spacing: Spacing.spacing4) {
            Text("음료가 준비되면 바로 알려드려요")
                .font(Typography.bodyXlBold)
                .foregroundStyle(Colors.textStrong)
            Text("알림을 켜면 주문 진행 상황을 바로 알 수 있어요")
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textTertiary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Spacing.spacing24)
        .padding(.vertical, Spacing.spacing16)
    }

    private var bellIcon: some View {
        Circle()
            .fill(Colors.fillBrandWeak)
            .frame(width: 64, height: 64)
            .overlay(
                Image(.bellRingIcon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .keyframeAnimator(initialValue: BellShakeMotion(), trigger: appeared) { content, motion in
                        content.rotationEffect(.degrees(motion.rotationDegrees))
                    } keyframes: { _ in
                        KeyframeTrack(\.rotationDegrees) {
                            LinearKeyframe(0, duration: 0.85)
                            LinearKeyframe(14, duration: 0.12, timingCurve: Self.easeInOutCurve)
                            LinearKeyframe(-12, duration: 0.12, timingCurve: Self.easeInOutCurve)
                            LinearKeyframe(8, duration: 0.12, timingCurve: Self.easeInOutCurve)
                            LinearKeyframe(-4, duration: 0.12, timingCurve: Self.easeInOutCurve)
                            LinearKeyframe(0, duration: 0.12, timingCurve: Self.easeInOutCurve)
                        }
                    }
            )
            .keyframeAnimator(initialValue: BellTileMotion(), trigger: appeared) { content, motion in
                content
                    .scaleEffect(motion.scale)
                    .opacity(motion.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0.6, duration: 0.6)
                    LinearKeyframe(1, duration: 0.25, timingCurve: Self.bounceCurve)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: 0.6)
                    LinearKeyframe(1, duration: 0.12, timingCurve: Self.easeOutCurve)
                }
            }
    }

    private var footer: some View {
        HStack(spacing: Spacing.spacing8) {
            Button(action: onSkip) {
                Text("다음에")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)

            Button(action: onAllow) {
                Text("알림 받기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing16)
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        NotificationPermissionSheet(onSkip: {}, onAllow: {})
    }
}
