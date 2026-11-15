import SwiftUI

struct BottomSheetContainer<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content

    @State private var dimOpacity: Double = 0
    @State private var sheetOffset: CGFloat = Self.offscreenOffset
    @State private var dragOffset: CGFloat = 0

    private static var offscreenOffset: CGFloat { 500 }

    var body: some View {
        ZStack(alignment: .bottom) {
            Colors.backgroundDim
                .ignoresSafeArea()
                .opacity(dimOpacity)
                .allowsHitTesting(isPresented)
                .onTapGesture { dismiss() }

            sheetCard
                .offset(y: sheetOffset + dragOffset)
                .allowsHitTesting(isPresented)
        }
        .onChange(of: isPresented) {
            if isPresented {
                // Figma smart-animate 타이밍: Dim 0~10%(200ms) ease-out, Sheet 0~19%(380ms) ease-out
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 1
                }
                withAnimation(.easeOut(duration: 0.38)) {
                    sheetOffset = 0
                }
            } else {
                dragOffset = 0
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 0
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
        .padding(.bottom, Spacing.spacing16)
        .frame(maxWidth: .infinity)
        .background(Colors.backgroundFloated)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Radius.sheet,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: Radius.sheet
            )
        )
        .compositingGroup()
        .shadow(color: Colors.shadowMedium, radius: 16, x: 0, y: 8)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = max(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height > 80 {
                        dismiss()
                    } else {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = 0
                        }
                    }
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
        isPresented = false
    }
}
