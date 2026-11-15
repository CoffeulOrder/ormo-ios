import SwiftUI

struct PasswordSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PasswordSetupViewModel()
    @State private var termsViewModel = TermsAgreementViewModel()
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
        Text("비밀번호를 입력해주세요")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isTitleVisible ? 1 : 0)
            .offset(y: isTitleVisible ? 0 : 10)
    }

    private var fieldsView: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing20) {
            passwordField
            passwordConfirmationField
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            toggleableSecureField(text: $viewModel.password, isVisible: $viewModel.isPasswordVisible)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Colors.fieldBorder, lineWidth: 1)
                )

            HStack(spacing: Spacing.spacing12) {
                passwordRuleRow(title: "8자 이상", isSatisfied: viewModel.hasMinLength)
                passwordRuleRow(title: "영문과 숫자 포함", isSatisfied: viewModel.hasLetterAndDigit)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func passwordRuleRow(title: String, isSatisfied: Bool) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.checkIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .opacity(isSatisfied ? 1 : 0.35)

            Text(title)
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textPrimary)
        }
    }

    private var passwordConfirmationField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text("비밀번호 확인")
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textSecondary)

            toggleableSecureField(text: $viewModel.passwordConfirmation, isVisible: $viewModel.isPasswordConfirmationVisible)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(
                            viewModel.isMismatched ? Colors.borderDanger : Colors.fieldBorder,
                            lineWidth: viewModel.isMismatched ? 2 : 1
                        )
                )

            if viewModel.isMismatched {
                errorFooter
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var errorFooter: some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.errorIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text("비밀번호가 서로 달라요")
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textDanger)
        }
    }

    private func toggleableSecureField(text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Group {
                if isVisible.wrappedValue {
                    TextField("", text: text)
                } else {
                    SecureField("", text: text)
                }
            }
            .font(Typography.bodyMdRegular)
            .foregroundStyle(Colors.textPrimary)

            Button(action: { isVisible.wrappedValue.toggle() }) {
                Image(isVisible.wrappedValue ? .eyeIcon : .eyeOffIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing16)
        .frame(height: 56)
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            Button(action: { isTermsSheetVisible = true }) {
                Text("확인")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(viewModel.isValid ? Colors.textOnFill : Colors.textQuaternary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isValid ? Colors.fillBrand : Colors.fillNeutralWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isValid)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .opacity(isBottomCTAVisible ? 1 : 0)
        .offset(y: isBottomCTAVisible ? 0 : 32)
    }
}

#Preview {
    PasswordSetupView()
}
