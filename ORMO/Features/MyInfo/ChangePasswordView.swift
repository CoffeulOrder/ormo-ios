import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ChangePasswordViewModel
    let onLogout: (String?) -> Void

    init(email: String, onLogout: @escaping (String?) -> Void) {
        _viewModel = State(initialValue: ChangePasswordViewModel(email: email))
        self.onLogout = onLogout
    }

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleView
                    fieldsView
                }
            }
            bottomCTA
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: viewModel.isCompleted) {
            if viewModel.isCompleted {
                onLogout("비밀번호를 변경했어요")
            }
        }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image(.arrowBackIos)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var titleView: some View {
        Text("비밀번호를 변경해주세요")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fieldsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing24) {
            newPasswordField
            passwordConfirmationField
        }
        .padding(Spacing.spacing20)
    }

    private func fieldBorderColor(isInvalid: Bool) -> Color {
        isInvalid ? Colors.borderDanger : Colors.fieldBorder
    }

    private func fieldBorderWidth(isInvalid: Bool) -> CGFloat {
        isInvalid ? 2 : 1
    }

    private var newPasswordField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("새 비밀번호")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing8) {
                Group {
                    if viewModel.isPasswordVisible {
                        TextField("", text: $viewModel.password)
                    } else {
                        SecureField("", text: $viewModel.password)
                    }
                }
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .submitLabel(.next)

                Button(action: { viewModel.isPasswordVisible.toggle() }) {
                    Image(viewModel.isPasswordVisible ? .eyeIcon : .eyeOffIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        fieldBorderColor(isInvalid: viewModel.isSameAsCurrentPassword),
                        lineWidth: fieldBorderWidth(isInvalid: viewModel.isSameAsCurrentPassword)
                    )
            )

            if viewModel.isSameAsCurrentPassword {
                errorFooter("기존 비밀번호와 다른 비밀번호를 입력해 주세요")
            } else {
                HStack(spacing: Spacing.spacing12) {
                    passwordRuleRow(title: "8자 이상", isSatisfied: viewModel.hasMinLength)
                    passwordRuleRow(title: "영문과 숫자 포함", isSatisfied: viewModel.hasLetterAndDigit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func passwordRuleRow(title: String, isSatisfied: Bool) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(isSatisfied ? .checkIconBlue : .checkIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text(title)
                .font(Typography.bodySmMedium)
                .foregroundStyle(isSatisfied ? Colors.textBrand : Colors.textTertiary)
        }
    }

    private var passwordConfirmationField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("새 비밀번호 확인")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing8) {
                Group {
                    if viewModel.isPasswordConfirmationVisible {
                        TextField("", text: $viewModel.passwordConfirmation)
                    } else {
                        SecureField("", text: $viewModel.passwordConfirmation)
                    }
                }
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .submitLabel(.done)
                .onSubmit(confirmTapped)

                Button(action: { viewModel.isPasswordConfirmationVisible.toggle() }) {
                    Image(viewModel.isPasswordConfirmationVisible ? .eyeIcon : .eyeOffIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        fieldBorderColor(isInvalid: viewModel.isPasswordMismatched),
                        lineWidth: fieldBorderWidth(isInvalid: viewModel.isPasswordMismatched)
                    )
            )

            if viewModel.isPasswordMismatched {
                errorFooter("비밀번호가 일치하지 않아요")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorFooter(_ message: String) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.errorIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text(message)
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textDanger)
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            Button(action: confirmTapped) {
                Text("변경하기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(viewModel.isFormValid ? Colors.textOnFill : Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isFormValid ? Colors.fillBrand : Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isFormValid)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
    }

    private func confirmTapped() {
        Task { await viewModel.submitTapped() }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView(email: "ormo@eulji.ac.kr", onLogout: { _ in })
    }
}
