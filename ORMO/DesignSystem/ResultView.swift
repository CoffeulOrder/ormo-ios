import SwiftUI

// 처리 결과·빈 상태·오류를 화면 가운데에서 알려주는 공용 뷰 (Figma "Result" 컴포넌트).
struct ResultView: View {
    let icon: ImageResource
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: Spacing.spacing20) {
            ZStack {
                Circle().fill(Colors.fillNeutralWeak)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
            .frame(width: 60, height: 60)

            VStack(spacing: Spacing.spacing16) {
                VStack(spacing: Spacing.spacing4) {
                    Text(title)
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textStrong)
                    Text(message)
                        .font(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textSecondary)
                }
                .multilineTextAlignment(.center)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .padding(.horizontal, Spacing.spacing16)
                        .frame(height: 38)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Figma control-radius-38 = 10px (토큰 없음)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.spacing40)
        .padding(.top, Spacing.spacing32)
        .padding(.bottom, Spacing.spacing40)
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    ResultView(
        icon: .coffeeIcon,
        title: "아직 메뉴가 없어요",
        message: "메뉴를 준비하고 있어요",
        buttonTitle: "다른 매장 보기",
        action: {}
    )
}
