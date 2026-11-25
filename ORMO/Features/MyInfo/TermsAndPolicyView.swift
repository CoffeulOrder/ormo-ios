import SwiftUI

struct TermsAndPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            VStack(alignment: .leading, spacing: 0) {
                listItem("서비스 이용약관") { router.path.append(HomeRoute.termsDocument(.serviceTerms)) }
                listItem("개인정보 처리방침") { router.path.append(HomeRoute.termsDocument(.privacyPolicy)) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("약관 및 정책")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)

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
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private func listItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing12) {
                Text(title)
                    .typography(Typography.bodyMdMedium)
                    .foregroundStyle(Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(.chevronRight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Colors.iconTertiary)
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, Spacing.spacing12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TermsAndPolicyView()
    }
    .environment(HomeRouter())
}
