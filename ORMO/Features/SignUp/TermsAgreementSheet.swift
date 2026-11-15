import SwiftUI

struct TermsAgreementSheet: View {
    @Bindable var viewModel: TermsAgreementViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스 이용에\n필요한 동의만 추렸어요")
                .font(Typography.bodyXlBold)
                .foregroundStyle(Colors.textStrong)
                .padding(.horizontal, Spacing.spacing24)
                .padding(.vertical, Spacing.spacing16)

            VStack(spacing: 0) {
                row(title: "전체 동의", titleFont: Typography.bodyLgBold, isAgreed: viewModel.isAllAgreed, action: viewModel.toggleAll)

                ForEach(viewModel.items) { item in
                    row(title: item.title, titleFont: Typography.bodySmMedium, isAgreed: item.isAgreed) {
                        viewModel.toggle(item)
                    }
                }
            }
            .padding(Spacing.spacing16)
            .padding(.horizontal, Spacing.spacing24)

            Button(action: viewModel.submitTapped) {
                Text("동의하고 가입하기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(viewModel.canSubmit ? Colors.textOnFill : Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.canSubmit ? Colors.fillBrand : Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSubmit)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)
        }
    }

    private func row(title: String, titleFont: Font, isAgreed: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing8) {
                Image(isAgreed ? .checkIconBlue : .checkIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .keyframeAnimator(initialValue: CGFloat(1), trigger: isAgreed) { content, scale in
                        content.scaleEffect(scale)
                    } keyframes: { _ in
                        KeyframeTrack {
                            CubicKeyframe(1.25, duration: 0.1)
                            CubicKeyframe(1.0, duration: 0.15)
                        }
                    }

                Text(title)
                    .font(titleFont)
                    .foregroundStyle(Colors.textPrimary)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TermsAgreementSheet(viewModel: TermsAgreementViewModel())
}
