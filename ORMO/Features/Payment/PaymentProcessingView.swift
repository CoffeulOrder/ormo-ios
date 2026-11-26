import SwiftUI

struct PaymentProcessingView: View {
    @Environment(HomeRouter.self) private var router
    @State private var viewModel: PaymentProcessingViewModel

    init(paymentMethod: PaymentMethod, totalPrice: Int, storeName: String, cart: CartStore) {
        _viewModel = State(initialValue: PaymentProcessingViewModel(
            paymentMethod: paymentMethod,
            totalPrice: totalPrice,
            storeName: storeName,
            cart: cart
        ))
    }

    private struct SymbolMotion {
        var cupScaleY: CGFloat = 1
        var steamLRotationDegrees: Double = 0
        var steamLTranslateY: CGFloat = 0
        var steamLOpacity: Double = 1
        var steamRRotationDegrees: Double = 0
        var steamRTranslateY: CGFloat = 0
        var steamROpacity: Double = 1
    }

    private struct TextMotion {
        var translateY: CGFloat = 0
        var opacity: Double = 1
    }

    private static let easeOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )
    private static let easeInCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.42, y: 0),
        endControlPoint: UnitPoint(x: 1, y: 1)
    )
    private static let easeInOutCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.42, y: 0),
        endControlPoint: UnitPoint(x: 0.58, y: 1)
    )

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            symbolView

            textView
                .padding(.top, Spacing.spacing56)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.submit()
        }
        .onChange(of: viewModel.outcome) {
            switch viewModel.outcome {
            case .success:
                if let pickupNumber = viewModel.completedOrderPickupNumber {
                    router.path.append(
                        HomeRoute.orderComplete(pickupNumber: pickupNumber, storeName: viewModel.storeName, queueCount: 3)
                    )
                }
            case .failure:
                router.path.append(
                    HomeRoute.paymentFailure(
                        attemptId: UUID(),
                        paymentMethod: viewModel.paymentMethod,
                        totalPrice: viewModel.totalPrice,
                        storeName: viewModel.storeName
                    )
                )
            case .expired:
                router.path.append(HomeRoute.paymentExpired)
            case nil:
                break
            }
        }
    }

    // Figma "3.2.2 결제 확인 중" 모션(3초 반복)을 그대로 옮겼다: 컵이 1초마다 한 번씩 숨 쉬듯 눌렸다 펴지고,
    // 왼쪽·오른쪽 김이 서로 엇갈린 타이밍으로 솟아올랐다 가라앉으며 흐려졌다 다시 선명해진다.
    private var symbolView: some View {
        Color.clear
            .frame(width: 100.54, height: 128)
            .keyframeAnimator(initialValue: SymbolMotion(), repeating: true) { _, motion in
                ZStack(alignment: .topLeading) {
                    Image(.ormoCup)
                        .resizable()
                        .frame(width: 97.41, height: 86.11)
                        .scaleEffect(x: 1, y: motion.cupScaleY, anchor: .center)
                        .offset(x: 1.55, y: 40.35)

                    Image(.ormoSteamL)
                        .resizable()
                        .frame(width: 19.97, height: 26.7)
                        .rotationEffect(.degrees(motion.steamLRotationDegrees))
                        .opacity(motion.steamLOpacity)
                        .offset(x: 35.47, y: 13.16 + motion.steamLTranslateY)

                    Image(.ormoSteamR)
                        .resizable()
                        .frame(width: 26.17, height: 36.59)
                        .rotationEffect(.degrees(motion.steamRRotationDegrees))
                        .opacity(motion.steamROpacity)
                        .offset(x: 57.49, y: 1.57 + motion.steamRTranslateY)
                }
                .frame(width: 100.54, height: 128, alignment: .topLeading)
            } keyframes: { _ in
                KeyframeTrack(\.cupScaleY) {
                    LinearKeyframe(0.97, duration: 0.2, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 0.3, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.5)
                    LinearKeyframe(0.97, duration: 0.2, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 0.3, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.5)
                    LinearKeyframe(0.97, duration: 0.2, timingCurve: Self.easeOutCurve)
                    LinearKeyframe(1, duration: 0.3, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.5)
                }
                KeyframeTrack(\.steamLRotationDegrees) {
                    LinearKeyframe(6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                }
                KeyframeTrack(\.steamLTranslateY) {
                    LinearKeyframe(-8, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-8, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-8, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                }
                KeyframeTrack(\.steamLOpacity) {
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15)
                }
                KeyframeTrack(\.steamRRotationDegrees) {
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-6, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                }
                KeyframeTrack(\.steamRTranslateY) {
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-10, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-10, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.15)
                    LinearKeyframe(-10, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(0, duration: 0.45, timingCurve: Self.easeInOutCurve)
                }
                KeyframeTrack(\.steamROpacity) {
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(0.55, duration: 0.4, timingCurve: Self.easeInOutCurve)
                    LinearKeyframe(1, duration: 0.45, timingCurve: Self.easeInOutCurve)
                }
            }
    }

    // 2.7초는 그대로 있다가 마지막 0.3초 동안 살짝 떠오르며 사라진다. 반복(loop)이라 다음 바퀴 시작에 바로 되돌아온다.
    private var textView: some View {
        VStack(spacing: Spacing.spacing12) {
            Text("결제를 확인하고 있어요")
                .typography(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text("잠시만 기다려주세요")
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)
        }
        .keyframeAnimator(initialValue: TextMotion(), repeating: true) { content, motion in
            content
                .offset(y: motion.translateY)
                .opacity(motion.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.translateY) {
                LinearKeyframe(0, duration: 2.7)
                LinearKeyframe(-6, duration: 0.3, timingCurve: Self.easeInCurve)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(1, duration: 2.7)
                LinearKeyframe(0, duration: 0.3, timingCurve: Self.easeInCurve)
            }
        }
    }
}

#Preview {
    PaymentProcessingView(paymentMethod: .tossPay, totalPrice: 12000, storeName: "을지대학교 범석관 카페", cart: CartStore())
        .environment(HomeRouter())
}
