import SwiftUI

struct SignUpProfileView: View {
    @Environment(SignUpRouter.self) private var router
    @State private var viewModel = SignUpProfileViewModel()
    @State private var termsViewModel = TermsAgreementViewModel()
    private let signUpRepository: SignUpRepository = MockSignUpRepository()
    @State private var isTermsSheetVisible = false
    @State private var isTitleVisible = false
    @State private var isBottomCTAVisible = false

    var body: some View {
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

            BottomSheetContainer(isPresented: $isTermsSheetVisible, bottomPadding: Spacing.spacing32) {
                TermsAgreementSheet(viewModel: termsViewModel)
            }
            .ignoresSafeArea(edges: .bottom)
        }
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
        .onChange(of: termsViewModel.isCompleted) {
            if termsViewModel.isCompleted {
                isTermsSheetVisible = false
                termsViewModel.isCompleted = false
                Task {
                    try? await signUpRepository.completeSignUp(
                        email: router.signUpEmail,
                        password: router.signUpPassword,
                        name: router.userName
                    )
                    router.push(.completion)
                }
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
        case .name: "이름을 입력해주세요"
        case .password: "비밀번호를 입력해주세요"
        case .passwordConfirmation: "비밀번호를 한 번 더 입력해주세요"
        }
    }

    private var titleView: some View {
        Text(titleText)
            .typography(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isTitleVisible ? 1 : 0)
            .offset(y: isTitleVisible ? 0 : 10)
    }

    // 쌓기 패턴: 지금 입력 중인 칸이 맨 위, 이미 확정한 칸들은 아래로 회색 읽기 전용으로 쌓인다.
    private var fieldsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing24) {
            switch viewModel.step {
            case .name:
                nameField(isActive: true)
            case .password:
                passwordGroup(isActive: true)
                nameField(isActive: false)
            case .passwordConfirmation:
                passwordConfirmationField
                passwordGroup(isActive: false)
                nameField(isActive: false)
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

    private func nameField(isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("이름")
                .typography(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            Group {
                if isActive {
                    TextField(
                        "",
                        text: Binding(
                            get: { viewModel.name },
                            set: { viewModel.nameChanged(to: $0) }
                        ),
                        prompt: Text("오르모").foregroundStyle(Colors.textQuaternary)
                    )
                    .submitLabel(.next)
                    .onSubmit(confirmTapped)
                } else {
                    Text(viewModel.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .typography(Typography.bodyMdRegular)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        fieldBorderColor(isActive: isActive, isInvalid: isActive && viewModel.hasInvalidNameCharacters),
                        lineWidth: fieldBorderWidth(isActive: isActive, isInvalid: isActive && viewModel.hasInvalidNameCharacters)
                    )
            )

            if isActive && viewModel.hasInvalidNameCharacters {
                errorFooter("이름은 한글과 영문만 입력할 수 있어요")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func passwordGroup(isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호")
                .typography(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            passwordDisplay(isActive: isActive)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(
                            fieldBorderColor(isActive: isActive, isInvalid: false),
                            lineWidth: fieldBorderWidth(isActive: isActive, isInvalid: false)
                        )
                )

            HStack(spacing: Spacing.spacing12) {
                passwordRuleRow(title: "8자 이상", isSatisfied: viewModel.hasMinLength)
                passwordRuleRow(title: "영문과 숫자 포함", isSatisfied: viewModel.hasLetterAndDigit)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func passwordDisplay(isActive: Bool) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Group {
                if isActive {
                    if viewModel.isPasswordVisible {
                        TextField("", text: $viewModel.password)
                    } else {
                        SecureField("", text: $viewModel.password)
                    }
                } else {
                    Text(viewModel.isPasswordVisible ? viewModel.password : String(repeating: "•", count: viewModel.password.count))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .typography(Typography.bodyMdRegular)
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
                .typography(Typography.bodySmMedium)
                .foregroundStyle(isSatisfied ? Colors.textBrand : Colors.textTertiary)
        }
    }

    private var passwordConfirmationField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호 확인")
                .typography(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing8) {
                Group {
                    if viewModel.isPasswordConfirmationVisible {
                        TextField("", text: $viewModel.passwordConfirmation)
                    } else {
                        SecureField("", text: $viewModel.passwordConfirmation)
                    }
                }
                .typography(Typography.bodyMdRegular)
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
                errorFooter("비밀번호가 서로 달라요")
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
                .typography(Typography.bodySmRegular)
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
                    .typography(Typography.bodyLgSemibold)
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
        .ignoresSafeArea(edges: .bottom)
    }

    private func backTapped() {
        // 이름 단계에서만 0.2.1 이메일 화면으로 나가고, 비밀번호 단계에서는 이름 단계로 돌아간다.
        if viewModel.step == .name {
            router.path = NavigationPath([SignUpRoute.email])
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                viewModel.step = .name
            }
        }
    }

    private func confirmTapped() {
        switch viewModel.step {
        case .name:
            guard viewModel.isNameValid else { return }
            viewModel.confirmNameTapped()
            router.userName = viewModel.name
        case .password:
            viewModel.confirmPasswordTapped()
        case .passwordConfirmation:
            guard viewModel.isPasswordConfirmationValid else { return }
            router.signUpPassword = viewModel.password
            isTermsSheetVisible = true
        }
    }
}

#Preview {
    SignUpProfileView()
        .environment(SignUpRouter())
}
