import SwiftUI

struct LoginView: View {
    var onSignUpCompleted: () -> Void = {}

    @State private var viewModel = LoginViewModel()
    @State private var isTitleVisible = false
    @State private var isBottomCTAVisible = false
    @State private var snackbarOffset: CGFloat = 24
    @State private var snackbarOpacity: Double = 0
    @State private var dimOpacity: Double = 0
    @State private var dialogScale: CGFloat = 0.94
    @State private var dialogOpacity: Double = 0
    @State private var signUpRouter = SignUpRouter()

    var body: some View {
        NavigationStack(path: $signUpRouter.path) {
            content
                .navigationDestination(for: SignUpRoute.self) { route in
                    switch route {
                    case .email:
                        SignUpEmailView()
                    case .verificationCode:
                        VerificationCodeView()
                    case .nameInput:
                        NameInputView()
                    case .passwordSetup:
                        PasswordSetupView()
                    case .completion:
                        SignUpCompletionView(name: signUpRouter.userName, onFinished: onSignUpCompleted)
                    }
                }
        }
        .environment(signUpRouter)
    }

    private var content: some View {
        ZStack(alignment: .top) {
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

            snackbar
                .padding(.top, Spacing.spacing8)
                .offset(y: snackbarOffset)
                .opacity(snackbarOpacity)

            ZStack {
                Colors.backgroundDim
                    .ignoresSafeArea()
                    .opacity(dimOpacity)

                AlertDialog(
                    title: "이용이 제한된 계정이에요",
                    message: "궁금한 점은 고객센터로 문의해 주세요",
                    secondaryTitle: "닫기",
                    primaryTitle: "문의하기",
                    secondaryAction: viewModel.dismissRestrictedAccountDialog,
                    primaryAction: viewModel.contactSupportTapped
                )
                .scaleEffect(dialogScale)
                .opacity(dialogOpacity)
                .compositingGroup()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(viewModel.isRestrictedAccountDialogVisible)

            BottomSheetContainer(isPresented: $viewModel.isSchoolEmailDomainSheetVisible) {
                SchoolEmailDomainSheet(
                    domains: viewModel.schoolEmailDomains,
                    selectedDomain: viewModel.selectedSchoolEmailDomain,
                    onSelect: viewModel.selectSchoolEmailDomain
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .task {
            await viewModel.loadSchoolEmailDomainsIfNeeded()
        }
        .onAppear {
            // Figma smart-animate 타이밍: Title 0~17.5%(350ms), Bottom CTA 6~26%(지연 120ms, 400ms), ease-out
            withAnimation(.easeOut(duration: 0.35)) {
                isTitleVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.12)) {
                isBottomCTAVisible = true
            }
        }
        .onChange(of: viewModel.isSnackbarVisible) {
            if viewModel.isSnackbarVisible {
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    snackbarOffset = 0
                    snackbarOpacity = 1
                }
            } else {
                withAnimation(.easeOut(duration: 0.25)) {
                    snackbarOffset = 24
                    snackbarOpacity = 0
                }
            }
        }
        .onChange(of: viewModel.isRestrictedAccountDialogVisible) {
            if viewModel.isRestrictedAccountDialogVisible {
                // Figma smart-animate 타이밍: Dim 0~10%(200ms), Dialog 2.5~15%(지연 50ms, scale 250ms·opacity 200ms), cubic-bezier(0.45, 1.45, 0.8, 1)
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 1
                }
                withAnimation(.timingCurve(0.45, 1.45, 0.8, 1, duration: 0.25).delay(0.05)) {
                    dialogScale = 1
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
                    dialogOpacity = 1
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    dimOpacity = 0
                    dialogScale = 0.94
                    dialogOpacity = 0
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var snackbar: some View {
        HStack(spacing: Spacing.spacing12) {
            Image(.alertIconLarge)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("비밀번호를 5회 틀렸어요")
                .font(Typography.bodyMdSemibold)
                .foregroundStyle(Colors.textOnFill)
        }
        .padding(.leading, Spacing.spacing16)
        .padding(.trailing, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutral)
        .clipShape(Capsule())
    }

    // 디자이너 확인 결과 뒤로가기 버튼은 실수로 들어간 요소라 제거했다. 상단 여백 유지를 위해 빈 바만 남긴다.
    private var topNavigationBar: some View {
        Color.clear
            .frame(height: 56)
            .background(Colors.backgroundDefault)
    }

    private var titleView: some View {
        Text("학교 이메일로\n로그인해 주세요")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
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

                Text("@\(viewModel.selectedSchoolEmailDomain)")
                    .foregroundStyle(Colors.textQuaternary)

                if viewModel.hasMultipleSchoolEmailDomains {
                    Button(action: viewModel.selectSchoolEmailTapped) {
                        Image(.chevronDown)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
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
                    Text(viewModel.isLockedOut ? viewModel.lockoutCountdownText : "로그인")
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(viewModel.isLockedOut ? Colors.textQuaternary : Colors.textOnFill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.isLockedOut ? Colors.fillNeutralWeak : Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLockedOut)
                .padding(.horizontal, Spacing.spacing20)

                HStack(spacing: Spacing.spacing4) {
                    Button(action: viewModel.forgotPasswordTapped) {
                        Text(viewModel.isLockedOut ? "비밀번호 재설정하기" : "비밀번호 찾기")
                            .font(Typography.bodyMdMedium)
                            .foregroundStyle(Colors.textTertiary)
                    }
                    .buttonStyle(.plain)

                    Text("|")
                        .font(Typography.bodyMdMedium)
                        .foregroundStyle(Colors.textTertiary)

                    Button(action: { signUpRouter.push(.email) }) {
                        Text("회원가입")
                            .font(Typography.bodyMdMedium)
                            .foregroundStyle(Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.spacing16)
                .frame(height: 40)
                .padding(.top, Spacing.spacing8)
                .padding(.horizontal, Spacing.spacing24)
                .frame(maxWidth: .infinity)
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
