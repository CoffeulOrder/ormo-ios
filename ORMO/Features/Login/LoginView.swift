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

            Button(action: viewModel.selectSchoolEmailTapped) {
                HStack(spacing: Spacing.spacing8) {
                    Text(viewModel.selectedSchoolEmail ?? "ORMO")
                        .font(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textQuaternary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("@eulji.ac.kr")
                        .font(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textQuaternary)

                    Image(.chevronDown)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, Spacing.spacing16)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Colors.fieldBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .stroke(Colors.fieldBorder, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
