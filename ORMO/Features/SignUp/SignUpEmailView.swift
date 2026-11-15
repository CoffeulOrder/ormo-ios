import SwiftUI

struct SignUpEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SignUpRouter.self) private var router
    @State private var viewModel = SignUpEmailViewModel()
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

            BottomSheetContainer(isPresented: $viewModel.isSchoolEmailDomainSheetVisible) {
                SchoolEmailDomainSheet(
                    domains: viewModel.schoolEmailDomains,
                    selectedDomain: viewModel.selectedSchoolEmailDomain,
                    onSelect: viewModel.selectSchoolEmailDomain
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
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
        Text("학교 이메일을 입력해주세요")
            .font(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isTitleVisible ? 1 : 0)
            .offset(y: isTitleVisible ? 0 : 10)
    }

    private var fieldsView: some View {
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
                    .stroke(Colors.fieldBorder, lineWidth: 1)
            )
        }
        .padding(Spacing.spacing20)
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

            Button(action: { router.push(.verificationCode) }) {
                Text("인증코드 받기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .opacity(isBottomCTAVisible ? 1 : 0)
        .offset(y: isBottomCTAVisible ? 0 : 32)
    }
}

#Preview {
    SignUpEmailView()
        .environment(SignUpRouter())
}
