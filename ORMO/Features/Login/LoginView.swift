import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var isTitleVisible = false
    @State private var isBottomCTAVisible = false
    var onBack: () -> Void = {}

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
        .onAppear {
            // Figma smart-animate 타이밍: Title 0~17.5%(350ms), Bottom CTA 6~26%(지연 120ms, 400ms), ease-out
            withAnimation(.easeOut(duration: 0.35)) {
                isTitleVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.12)) {
                isBottomCTAVisible = true
            }
        }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
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
        Text("학교 이메일로\n로그인해 주세요")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isTitleVisible ? 1 : 0)
            .offset(y: isTitleVisible ? 0 : 10)
    }

    private var fieldsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing24) {
            emailField
            passwordField
        }
        .padding(Spacing.spacing20)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("이메일")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing8) {
                TextField(
                    "",
                    text: $viewModel.emailLocalPart,
                    prompt: Text("ORMO").foregroundStyle(Colors.textQuaternary)
                )
                .foregroundStyle(Colors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)

                Text("@\(viewModel.schoolEmailDomain)")
                    .foregroundStyle(Colors.textQuaternary)

                Button(action: viewModel.selectSchoolEmailTapped) {
                    Image(.chevronDown)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .font(Typography.bodyMdRegular)
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        viewModel.emailErrorMessage == nil ? Colors.fieldBorder : Colors.borderDanger,
                        lineWidth: viewModel.emailErrorMessage == nil ? 1 : 2
                    )
            )
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: viewModel.emailShakeTrigger) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-8, duration: 0.06)
                    CubicKeyframe(7, duration: 0.06)
                    CubicKeyframe(-5, duration: 0.06)
                    CubicKeyframe(3, duration: 0.06)
                    CubicKeyframe(0, duration: 0.06)
                }
            }

            if let emailErrorMessage = viewModel.emailErrorMessage {
                errorFooter(emailErrorMessage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.emailLocalPart) {
            viewModel.emailErrorMessage = nil
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            SecureField(
                "",
                text: $viewModel.password,
                prompt: Text("비밀번호를 입력해 주세요").foregroundStyle(Colors.textQuaternary)
            )
            .font(Typography.bodyMdRegular)
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        viewModel.passwordErrorMessage == nil ? Colors.fieldBorder : Colors.borderDanger,
                        lineWidth: viewModel.passwordErrorMessage == nil ? 1 : 2
                    )
            )
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: viewModel.passwordShakeTrigger) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-8, duration: 0.06)
                    CubicKeyframe(7, duration: 0.06)
                    CubicKeyframe(-5, duration: 0.06)
                    CubicKeyframe(3, duration: 0.06)
                    CubicKeyframe(0, duration: 0.06)
                }
            }

            if let passwordErrorMessage = viewModel.passwordErrorMessage {
                errorFooter(passwordErrorMessage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.password) {
            viewModel.passwordErrorMessage = nil
        }
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

            VStack(spacing: 0) {
                Button(action: viewModel.loginTapped) {
                    Text("로그인")
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.spacing20)

                Button(action: viewModel.forgotPasswordOrSignUpTapped) {
                    Text("비밀번호 찾기 | 회원가입")
                        .font(Typography.bodyMdMedium)
                        .foregroundStyle(Colors.textPrimary)
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.spacing8)
            }
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .opacity(isBottomCTAVisible ? 1 : 0)
        .offset(y: isBottomCTAVisible ? 0 : 32)
    }
}

#Preview {
    LoginView()
}
