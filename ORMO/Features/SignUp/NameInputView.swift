import SwiftUI

struct NameInputView: View {
    @Environment(SignUpRouter.self) private var router
    @State private var viewModel = NameInputViewModel()
    @State private var isTitleVisible = false
    @State private var isBottomCTAVisible = false

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
    }

    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            Button(action: { router.path = NavigationPath([SignUpRoute.email]) }) {
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
        Text("이름을 입력해주세요")
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
            TextField(
                "",
                text: Binding(
                    get: { viewModel.name },
                    set: { viewModel.nameChanged(to: $0) }
                ),
                prompt: Text("오르모").foregroundStyle(Colors.textQuaternary)
            )
            .font(Typography.bodyMdRegular)
            .foregroundStyle(Colors.textPrimary)
            .submitLabel(.next)
            .onSubmit(goToPasswordSetup)
            .padding(.horizontal, Spacing.spacing16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        viewModel.hasInvalidCharacters ? Colors.borderDanger : Colors.fieldBorder,
                        lineWidth: viewModel.hasInvalidCharacters ? 2 : 1
                    )
            )

            if viewModel.hasInvalidCharacters {
                errorFooter
            }
        }
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var errorFooter: some View {
        HStack(spacing: Spacing.spacing4) {
            Image(.errorIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text("띄어쓰기로 시작하거나 특수문자는 쓸 수 없어요")
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

            Button(action: goToPasswordSetup) {
                Text("다음")
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

    private func goToPasswordSetup() {
        guard viewModel.isValid else { return }
        router.push(.passwordSetup)
    }
}

#Preview {
    NameInputView()
        .environment(SignUpRouter())
}
