import SwiftUI

// 바텀시트 배경(흰 카드의 위치 이동)과 그 안의 내용(텍스트 등 투명도)은 의도적으로 속도를
// 다르게 가져간다 — 배경이 내용보다 살짝 더 빨리 올라오고 내려간다. 내용물을 조건부로 표시하는
// 화면에서는 `withAnimation(BottomSheetMotion.contentAnimation) { isPresented = ... }`처럼
// contentAnimation으로 감싸야 한다(배경 쪽 속도는 BottomSheetContainer 내부에서 따로 적용한다).
enum BottomSheetMotion {
    // dampingFraction 1 = 임계 감쇠: 목표 지점을 지나쳐 튕기지 않고(오버슈트 없이) 가장 빠르게
    // 도달한다. 0.86처럼 1보다 작으면 스프링이 튕기며 "보잉보잉"거리는 느낌이 난다.
    static let contentAnimation = Animation.spring(response: 0.38, dampingFraction: 1, blendDuration: 0)
    // 배경(흰 카드)은 내용보다 조금 더 빠르게 올라오고 내려가도록 response를 더 짧게 둔다.
    static let backgroundAnimation = Animation.spring(response: 0.18, dampingFraction: 1, blendDuration: 0)
}

struct BottomSheetContainer<Content: View>: View {
    @Binding var isPresented: Bool
    var bottomPadding: CGFloat = Spacing.spacing16
    @ViewBuilder var content: () -> Content

    @State private var dimOpacity: Double = 0
    @State private var sheetOffset: CGFloat = Self.offscreenOffset
    // 드래그 중 손가락 위치와 어긋나거나 떨리던 문제는 @State를 직접 손으로 갱신하던 방식 때문이었다.
    // @GestureState는 드래그가 진행되는 동안 애니메이션 없이 손가락 이동을 그대로 반영하고,
    // 손을 떼면 자동으로 0으로(암시적 스프링으로) 돌아가 "놓으면 제자리로" 동작도 공짜로 얻는다.
    @GestureState private var dragTranslation: CGFloat = 0

    private static var offscreenOffset: CGFloat { 500 }

    var body: some View {
        ZStack(alignment: .bottom) {
            Colors.backgroundDim
                .ignoresSafeArea()
                .opacity(dimOpacity)
                .allowsHitTesting(isPresented)
                .onTapGesture { dismiss() }

            sheetCard
                .offset(y: sheetOffset + dragTranslation)
                // duration 기반 easeOut은 몇 개의 구간으로 보간해 계단처럼 보일 수 있다. spring은
                // 매 프레임(최대 120fps 디스플레이에서는 120번/초) 물리 방정식으로 다시 계산되는
                // 연속 곡선이라 훨씬 더 잘게 쪼개진, 끊김 없는 움직임이 나온다.
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 1, blendDuration: 0.1), value: dragTranslation)
                .allowsHitTesting(isPresented)
        }
        .onChange(of: isPresented) {
            if isPresented {
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 1
                }
                withAnimation(BottomSheetMotion.backgroundAnimation) {
                    sheetOffset = 0
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 0
                }
                // 닫을 때도 스프링을 써서 올라올 때와 같은 "부드럽게 내려가며 사라지는" 느낌을 낸다.
                withAnimation(BottomSheetMotion.backgroundAnimation) {
                    sheetOffset = Self.offscreenOffset
                }
            }
        }
    }

    private var sheetCard: some View {
        VStack(spacing: 0) {
            handle
            content()
        }
        .padding(.top, Spacing.spacing12)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity)
        .background(Colors.backgroundFloated)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Radius.xl,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: Radius.xl
            )
        )
        .compositingGroup()
        .shadow(color: Colors.shadowMedium, radius: 16, x: 0, y: 8)
        .gesture(
            DragGesture()
                .updating($dragTranslation) { value, state, _ in
                    state = max(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height > 80 {
                        dismiss()
                    }
                    // 기준(80pt) 미달이면 아무것도 안 해도 된다: 손을 떼는 순간 dragTranslation이
                    // @GestureState에 의해 자동으로 0으로 돌아가며 제자리로 스프링된다.
                }
        )
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: Radius.full)
            .fill(Colors.fieldBorder)
            .frame(width: 40, height: 4)
            .padding(.vertical, Spacing.spacing4)
    }

    private func dismiss() {
        // isPresented 자체는 내용(content) 쪽 속도로 감싼다 — 이 바인딩을 관찰하는 호출부(예:
        // 내용물을 조건부로 넣고 빼는 화면)의 .transition()이 이 트랜잭션을 그대로 물려받기 때문.
        // 배경(sheetOffset)은 onChange 안에서 backgroundAnimation으로 따로 덮어쓴다.
        withAnimation(BottomSheetMotion.contentAnimation) {
            isPresented = false
        }
    }
}
