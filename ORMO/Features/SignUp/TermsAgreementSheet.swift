import SwiftUI

struct TermsAgreementSheet: View {
    @Environment(SignUpRouter.self) private var router
    @Bindable var viewModel: TermsAgreementViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스 이용에\n필요한 동의만 추렸어요")
                .typography(Typography.bodyXlBold)
                .foregroundStyle(Colors.textStrong)
                .padding(.horizontal, Spacing.spacing20)
                .padding(.vertical, Spacing.spacing16)

            VStack(spacing: 0) {
                allAgreeRow

                Rectangle()
                    .fill(Colors.borderDefault)
                    .frame(height: 1)

                ForEach(viewModel.items) { item in
                    itemRow(item)
                }
            }
            .padding(Spacing.spacing16)
            .padding(.horizontal, Spacing.spacing20)

            Button(action: viewModel.submitTapped) {
                Text("동의하고 가입하기")
                    .typography(Typography.bodyLgSemibold)
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

    private var allAgreeRow: some View {
        Button(action: viewModel.toggleAll) {
            HStack(spacing: Spacing.spacing8) {
                animatedCheckbox(isAgreed: viewModel.isAllAgreed)

                Text("전체 동의")
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textPrimary)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private func itemRow(_ item: AgreementItem) -> some View {
        HStack(spacing: 0) {
            Button(action: { viewModel.toggle(item) }) {
                HStack(spacing: Spacing.spacing8) {
                    animatedCheckbox(isAgreed: item.isAgreed)

                    Text(item.title)
                        .typography(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: { router.push(.termsFullText(item.document)) }) {
                Image(.chevronRight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Colors.textTertiary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 44)
    }

    private func animatedCheckbox(isAgreed: Bool) -> some View {
        Checkbox(isSelected: isAgreed)
            .keyframeAnimator(initialValue: CGFloat(1), trigger: isAgreed) { content, scale in
                content.scaleEffect(scale)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(1.25, duration: 0.1)
                    CubicKeyframe(1.0, duration: 0.15)
                }
            }
    }
}

#Preview {
    TermsAgreementSheet(viewModel: TermsAgreementViewModel())
        .environment(SignUpRouter())
}
