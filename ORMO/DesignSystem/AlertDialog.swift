import SwiftUI

// secondaryTitle이 없으면 확인 버튼 하나만 있는 Single 레이아웃이 된다(Figma Alert Dialog · Single).
struct AlertDialog: View {
    // Figma "Alert Dialog" Tone: Neutral(Brand Solid) · Critical(Critical Solid, 되돌릴 수 없는 행동).
    enum Tone {
        case neutral
        case critical

        var primaryBackground: Color {
            switch self {
            case .neutral: Colors.fillBrand
            case .critical: Colors.fillDanger
            }
        }
    }

    let title: String
    let message: String
    var secondaryTitle: String?
    let primaryTitle: String
    var tone: Tone = .neutral
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

            if let secondaryTitle {
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
                            .background(tone.primaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.r14))
                    }
                    .buttonStyle(.plain)
                }
            } else {
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

#Preview("Neutral") {
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

#Preview("Critical") {
    ZStack {
        Colors.backgroundDim.ignoresSafeArea()
        AlertDialog(
            title: "주문을 취소할까요?",
            message: "결제 금액 전액을 환불해 드려요",
            secondaryTitle: "닫기",
            primaryTitle: "취소하기",
            tone: .critical
        )
    }
}
