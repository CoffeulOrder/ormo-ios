import SwiftUI

// Figma "Skeleton" — 콘텐츠가 로딩되는 동안 자리를 미리 보여주는 회색 뼈대.
// "반짝임(shimmer) 애니메이션은 개발에서 적용"이라고 명시돼 있어, 뼈대 모양 위에
// 대각선 밝은 띠가 반복해서 지나가는 효과를 직접 구현했다.
struct SkeletonLoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        ZStack {
            skeletonLayout
            shimmerBand
                .mask(skeletonLayout)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .onAppear {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                shimmerPhase = 2
            }
        }
    }

    private var skeletonLayout: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing16) {
            block(width: 120, height: 16)
            block(width: nil, height: 48, cornerRadius: Radius.md)
            ForEach(0..<6, id: \.self) { _ in listItem }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing24)
    }

    private var listItem: some View {
        HStack(spacing: Spacing.spacing12) {
            Circle()
                .fill(Colors.fillNeutralWeak)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                block(width: nil, height: 16)
                block(width: 140, height: 12)
            }
        }
        .padding(.vertical, Spacing.spacing12)
    }

    private func block(width: CGFloat?, height: CGFloat, cornerRadius: CGFloat = Radius.xs) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Colors.fillNeutralWeak)
            .frame(height: height)
            .frame(maxWidth: width ?? .infinity, alignment: .leading)
    }

    private var shimmerBand: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [.clear, Color.white.opacity(colorScheme == .dark ? 0.12 : 0.7), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: proxy.size.width * 0.5)
            .rotationEffect(.degrees(16))
            .offset(x: shimmerPhase * proxy.size.width)
        }
    }
}

#Preview {
    SkeletonLoadingView()
}
