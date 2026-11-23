import SwiftUI
import Lottie
import UserNotifications

struct OrderCompleteView: View {
    @Environment(HomeRouter.self) private var router
    let pickupNumber: Int
    let storeName: String
    let queueCount: Int

    @State private var appeared = false
    @State private var showNotificationSheet = false

    private struct FadeUpMotion {
        var translateY: CGFloat
        var opacity: Double = 0
    }

    private static let easeOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                symbolView

                pickupNumberLabel
                    .padding(.top, Spacing.spacing41)

                infoCard
                    .padding(.top, Spacing.spacing16)

                Spacer()

                bottomCTA
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Colors.backgroundDefault.ignoresSafeArea())

            if showNotificationSheet {
                NotificationPermissionSheet(onSkip: notificationSheetSkipTapped, onAllow: notificationSheetAllowTapped)
            }
        }
        .navigationBarHidden(true)
        .onAppear { appeared = true }
    }

    // Lottie(ormo-cup-check-badge, 375×812 캔버스)에 "ORMO Symbol"이 Figma 시작 좌표(137,233)에서
    // 최종 좌표(137,117)로 보잉하듯 튀어 오르며 자리 잡는 모션이 통째로 들어있다. 박스는 최종 위치
    // 크기(100.54×128)만 잡고, 올라오는 동안 잠깐 아래로 넘치는 부분은 클립하지 않고 그대로 보여준다.
    private var symbolView: some View {
        Color.clear
            .frame(width: 100.54, height: 128)
            .overlay(alignment: .topLeading) {
                LottieView(animation: .named("ormo-cup-check-badge"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .resizable()
                    .frame(width: 375, height: 812)
                    .offset(x: -137, y: -117)
            }
    }

    private var pickupNumberLabel: some View {
        VStack(spacing: 0) {
            Text("픽업 번호")
                .font(Typography.bodyXlRegular)
                .foregroundStyle(Colors.textTertiary)
            Text("\(pickupNumber)")
                .font(Typography.display2xlSemibold)
                .foregroundStyle(Colors.textPrimary)
        }
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 16), trigger: appeared) { content, motion in
            content
                .offset(y: motion.translateY)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(16, duration: 0.6)
                LinearKeyframe(0, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.6)
                LinearKeyframe(1, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
        }
    }

    private var infoCard: some View {
        VStack(spacing: 10) { // Figma 원본값이 10px (스페이싱 토큰 중 일치 항목 없음)
            infoRow("매장", storeName)
            infoRow("내 앞 대기", "\(queueCount)건")
            infoRow("현재 상태", "매장에서 확인하고 있어요")
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.fillNeutralWeak)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.spacing20)
        .keyframeAnimator(initialValue: FadeUpMotion(translateY: 16), trigger: appeared) { content, motion in
            content
                .offset(y: motion.translateY)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(16, duration: 0.72)
                LinearKeyframe(0, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.72)
                LinearKeyframe(1, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Colors.textTertiary)
            Spacer()
            Text(value)
                .foregroundStyle(Colors.textPrimary)
        }
        .font(Typography.bodyMdRegular)
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            VStack(spacing: Spacing.spacing8) {
                Button(action: orderStatusTapped) {
                    Text("주문 상태 보기")
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)

                Button(action: addMoreOrderTapped) {
                    Text("추가 주문하기")
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrandWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
            }
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
                LinearKeyframe(32, duration: 0.85)
                LinearKeyframe(0, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0, duration: 0.85)
                LinearKeyframe(1, duration: 0.35, timingCurve: Self.easeOutCurve)
            }
        }
    }

    // 지금은 재주문(첫 주문 아님) 판별 로직이 없어, 항상 첫 주문으로 가정하고 4.5.1 알림 권한
    // 시트를 먼저 보여준다.
    private func orderStatusTapped() {
        showNotificationSheet = true
    }

    private func notificationSheetSkipTapped() {
        showNotificationSheet = false
        router.path.append(HomeRoute.orderDetail(pickupNumber: pickupNumber, storeName: storeName))
    }

    // OS 알림 권한 팝업을 띄운 뒤에는 허용·거부 결과와 무관하게 주문 상세로 넘어간다.
    private func notificationSheetAllowTapped() {
        Task {
            _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            showNotificationSheet = false
            router.path.append(HomeRoute.orderDetail(pickupNumber: pickupNumber, storeName: storeName))
        }
    }

    private func addMoreOrderTapped() {
        router.path = NavigationPath()
    }
}

#Preview {
    OrderCompleteView(pickupNumber: 27, storeName: "범석관 카페", queueCount: 3)
        .environment(HomeRouter())
}
