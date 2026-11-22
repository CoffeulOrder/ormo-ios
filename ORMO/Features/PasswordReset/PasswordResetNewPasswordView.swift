import SwiftUI

struct PasswordResetNewPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SignUpRouter.self) private var router
    @State private var viewModel: PasswordResetNewPasswordViewModel
    @State private var isTitleVisible = false
    @State private var isBottomCTAVisible = false

    init(email: String) {
        _viewModel = State(initialValue: PasswordResetNewPasswordViewModel(email: email))
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
        .onAppear {
            // Figma smart-animate 타이밍: Title 0~17.5%(350ms), Bottom CTA 6~26%(지연 120ms, 400ms), ease-out
            withAnimation(.easeOut(duration: 0.35)) {
                isTitleVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.12)) {
                isBottomCTAVisible = true
            }
        }
        .onChange(of: viewModel.isCompleted) {
            if viewModel.isCompleted {
                router.path.append(PasswordResetRoute.completion)
            }
        }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Button(action: backTapped) {
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

    private var titleText: String {
        switch viewModel.step {
        case .password: "새 비밀번호를 입력해주세요"
        case .passwordConfirmation: "비밀번호를 한 번 더 입력해주세요"
        }
    }

    private var titleView: some View {
        Text(titleText)
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isTitleVisible ? 1 : 0)
            .offset(y: isTitleVisible ? 0 : 10)
    }

    // 쌓기 패턴: 지금 입력 중인 칸이 맨 위, 이미 확정한 칸은 아래로 회색 보더로 쌓인다.
    private var fieldsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing24) {
            switch viewModel.step {
            case .password:
                passwordGroup(isActive: true)
            case .passwordConfirmation:
                passwordConfirmationField
                passwordGroup(isActive: false)
            }
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeOut(duration: 0.3), value: viewModel.step)
    }

    private func fieldBorderColor(isActive: Bool, isInvalid: Bool) -> Color {
        if isInvalid { return Colors.borderDanger }
        if isActive { return Colors.fillBrand }
        return Colors.fieldBorder
    }

    private func fieldBorderWidth(isActive: Bool, isInvalid: Bool) -> CGFloat {
        (isActive || isInvalid) ? 2 : 1
    }

    private func passwordGroup(isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            passwordDisplay(isActive: isActive)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(
                            fieldBorderColor(isActive: isActive, isInvalid: isActive && viewModel.isSameAsCurrentPassword),
                            lineWidth: fieldBorderWidth(isActive: isActive, isInvalid: isActive && viewModel.isSameAsCurrentPassword)
                        )
                )

            if isActive && viewModel.isSameAsCurrentPassword {
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

    // 확정된 비밀번호 칸도 Figma에서는 눈 아이콘이 남아있어 다시 보일 수 있다 (가입 화면의 이름 칸과 다른 점).
    private func passwordDisplay(isActive: Bool) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Group {
                if viewModel.isPasswordVisible {
                    TextField("", text: $viewModel.password)
                } else {
                    SecureField("", text: $viewModel.password)
                }
            }
            .disabled(!isActive)
            .font(Typography.bodyMdRegular)
            .foregroundStyle(Colors.textPrimary)
            .submitLabel(.next)
            .onSubmit(confirmTapped)

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
            Text("비밀번호 확인")
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
                        fieldBorderColor(isActive: true, isInvalid: viewModel.isPasswordMismatched),
                        lineWidth: fieldBorderWidth(isActive: true, isInvalid: viewModel.isPasswordMismatched)
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
                Text("확인")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(viewModel.isCurrentStepValid ? Colors.textOnFill : Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isCurrentStepValid ? Colors.fillBrand : Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isCurrentStepValid)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .opacity(isBottomCTAVisible ? 1 : 0)
        .offset(y: isBottomCTAVisible ? 0 : 32)
    }

    private func backTapped() {
        // 비밀번호 단계에서만 이전 화면(인증 코드)으로 나가고, 확인 단계에서는 비밀번호 단계로 돌아간다.
        if viewModel.step == .password {
            dismiss()
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                viewModel.step = .password
            }
        }
    }

    private func confirmTapped() {
        switch viewModel.step {
        case .password:
            Task { await viewModel.confirmPasswordTapped() }
        case .passwordConfirmation:
            Task { await viewModel.submitTapped() }
        }
    }
}

#Preview {
    PasswordResetNewPasswordView(email: "ormo@eulji.ac.kr")
        .environment(SignUpRouter())
}
