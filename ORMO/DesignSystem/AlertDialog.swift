import SwiftUI

struct AlertDialog: View {
    let title: String
    let message: String
    let secondaryTitle: String
    let primaryTitle: String
    var secondaryAction: () -> Void = {}
    var primaryAction: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing24) {
            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                Text(title)
                    .font(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textStrong)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(message)
                    .font(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: Spacing.spacing8) {
                Button(action: secondaryAction) {
                    Text(secondaryTitle)
                        .font(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Colors.fillNeutralWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.r14))
                }
                .buttonStyle(.plain)

                Button(action: primaryAction) {
                    Text(primaryTitle)
                        .font(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.r14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.spacing24)
        .padding(.top, Spacing.spacing24)
        .padding(.bottom, Spacing.spacing16)
        .frame(width: 320)
        .background(Colors.backgroundFloated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xxl))
        .compositingGroup()
        .shadow(color: Colors.shadowMedium, radius: 16, x: 0, y: 8)
    }
}

#Preview {
    ZStack {
        Colors.backgroundDim.ignoresSafeArea()
        AlertDialog(
            title: "이용이 제한된 계정이에요",
            message: "궁금한 점은 고객센터로 문의해 주세요",
            secondaryTitle: "닫기",
            primaryTitle: "문의하기"
        )
    }
}
