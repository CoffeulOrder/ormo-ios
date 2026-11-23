import SwiftUI

extension View {
    // Figma Alert Dialog 등장·퇴장 모션(스프링으로 톡 튀며 커지고, 뗄 땐 빠르게 페이드아웃)을 표준화한
    // 수식어. OrderDetailView의 주문 취소 팝업에서 쓰던, scaleEffect·opacity를 직접 들고 withAnimation으로
    // 움직이는 방식(= .transition()에 애니메이션을 붙이는 방식은 실제로 재생되지 않았다)을 그대로 재사용한다.
    func alertDialogOverlay<DialogContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder dialog: @escaping () -> DialogContent
    ) -> some View {
        modifier(AlertDialogOverlayModifier(isPresented: isPresented, dialog: dialog))
    }
}

private struct AlertDialogOverlayModifier<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let dialog: () -> DialogContent

    @State private var isMounted = false
    @State private var dialogScale: CGFloat = 0.7
    @State private var dialogOpacity: Double = 0
    @State private var dimOpacity: Double = 0
    @State private var unmountTask: Task<Void, Never>?

    private static var openAnimation: Animation { .spring(response: 0.32, dampingFraction: 0.62) }
    private static var closeAnimation: Animation { .easeOut(duration: 0.15) }
    private static var dimAnimation: Animation { .easeOut(duration: 0.2) }
    private static var closeDuration: Double { 0.15 }

    func body(content: Content) -> some View {
        content
            .overlay {
                if isMounted {
                    ZStack {
                        Colors.backgroundDim
                            .ignoresSafeArea()
                            .opacity(dimOpacity)

                        dialog()
                            .scaleEffect(dialogScale)
                            .opacity(dialogOpacity)
                            .compositingGroup()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onChange(of: isPresented) {
                if isPresented {
                    unmountTask?.cancel()
                    dialogScale = 0.7
                    dialogOpacity = 0
                    dimOpacity = 0
                    isMounted = true
                    withAnimation(Self.dimAnimation) { dimOpacity = 1 }
                    withAnimation(Self.openAnimation) {
                        dialogScale = 1
                        dialogOpacity = 1
                    }
                } else {
                    withAnimation(Self.closeAnimation) {
                        dialogScale = 0.94
                        dialogOpacity = 0
                        dimOpacity = 0
                    }
                    unmountTask?.cancel()
                    unmountTask = Task {
                        try? await Task.sleep(for: .seconds(Self.closeDuration))
                        guard !Task.isCancelled else { return }
                        isMounted = false
                    }
                }
            }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    return VStack {
        Button("다이얼로그 열기") { isPresented = true }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Colors.backgroundDefault)
    .alertDialogOverlay(isPresented: $isPresented) {
        AlertDialog(
            title: "로그아웃할까요?",
            message: "학교 이메일로 다시 로그인해주세요",
            secondaryTitle: "취소",
            primaryTitle: "로그아웃",
            secondaryAction: { isPresented = false },
            primaryAction: { isPresented = false }
        )
    }
}
