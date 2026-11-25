import SwiftUI

struct WithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = WithdrawViewModel()
    let onWithdrawn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleView
                    passwordField
                    infoRows
                }
            }
            bottomCTA
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
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
        Text("탈퇴하기 전에\n확인해주세요")
            .typography(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호")
                .typography(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing8) {
                Group {
                    if viewModel.isPasswordVisible {
                        TextField("", text: $viewModel.password)
                    } else {
                        SecureField("", text: $viewModel.password)
                    }
                }
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .submitLabel(.done)

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
                        viewModel.isPasswordInvalid ? Colors.borderDanger : Colors.fieldBorder,
                        lineWidth: viewModel.isPasswordInvalid ? 2 : 1
                    )
            )

            if viewModel.isPasswordInvalid {
                errorFooter("비밀번호가 올바르지 않아요")
            }
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.password) {
            viewModel.isPasswordInvalid = false
        }
    }

    private func errorFooter(_ message: String) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.errorIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text(message)
                .typography(Typography.bodySmRegular)
                .foregroundStyle(Colors.textDanger)
        }
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing12) {
            infoRow("이름과 이메일은 바로 삭제돼요")
            infoRow("주문·결제 기록은 법에 따라 5년 동안 보관해요")
            infoRow("같은 이메일로 다시 가입할 수 있어요")
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing4)
    }

    private func infoRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing8) {
            Circle()
                .fill(Colors.textTertiary)
                .frame(width: 4, height: 4)
                .padding(.top, 8)

            Text(text)
                .typography(Typography.bodySmRegular)
                .foregroundStyle(Colors.textTertiary)
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

            Button(action: withdrawTapped) {
                Text("탈퇴하기")
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(viewModel.isFormValid ? Colors.textOnFill : Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isFormValid ? Colors.fillDanger : Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isFormValid)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func withdrawTapped() {
        Task {
            if await viewModel.withdrawTapped() {
                onWithdrawn()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WithdrawView(onWithdrawn: {})
    }
}
