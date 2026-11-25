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
            GeometryReader { proxy in
                // Figma 캔버스가 375pt 기준이라, 너비 비율로 두 여백(X 아이콘-컵 31 · 컵-픽업번호 46)을
                // 같은 비율로 스케일한다. 화면 높이와 무관하게 폭에 맞춰 반응형으로 늘고 줄어든다.
                let scale = proxy.size.width / 375

                VStack(spacing: 0) {
                    topNavigationBar
                        .padding(.bottom, 31 * scale)

                    symbolView

                    pickupNumberLabel
                        .padding(.top, 46 * scale)

                    infoCard(scale: scale)
                        .padding(.top, Spacing.spacing16)

                    Spacer()

                    bottomCTA(scale: scale)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .background(Colors.backgroundDefault.ignoresSafeArea())

            if showNotificationSheet {
                NotificationPermissionSheet(onSkip: notificationSheetSkipTapped, onAllow: notificationSheetAllowTapped)
            }
        }
        .navigationBarHidden(true)
        .onAppear { appeared = true }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Spacer()

            Button(action: closeTapped) {
                Image(.closeIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
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
                    .allowsHitTesting(false)
            }
    }

    private var pickupNumberLabel: some View {
        VStack(spacing: 0) {
            Text("픽업 번호")
                .typography(Typography.bodyXlRegular)
                .foregroundStyle(Colors.textTertiary)
            Text("\(pickupNumber)")
                .typography(Typography.display2xlSemibold)
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

    // Figma 원본 행간 10px(375pt 기준)을 화면 폭 비율로 스케일한다.
    private func infoCard(scale: CGFloat) -> some View {
        VStack(spacing: 10 * scale) {
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
        HStack(alignment: .top, spacing: Spacing.spacing16) {
            Text(label)
                .foregroundStyle(Colors.textTertiary)
                .fixedSize()
            Text(value)
                .foregroundStyle(Colors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .typography(Typography.bodyMdRegular)
    }

    private func bottomCTA(scale: CGFloat) -> some View {
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
                        .typography(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)

                Button(action: addMoreOrderTapped) {
                    Text("추가 주문하기")
                        .typography(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrandWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, 32 * scale)
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

    private func closeTapped() {
        router.path = NavigationPath()
    }
}

#Preview {
    OrderCompleteView(pickupNumber: 27, storeName: "범석관 카페", queueCount: 3)
        .environment(HomeRouter())
}
