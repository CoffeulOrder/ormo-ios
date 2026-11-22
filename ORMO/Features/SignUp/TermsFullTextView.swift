import SwiftUI

struct TermsFullTextView: View {
    @Environment(\.dismiss) private var dismiss
    let document: TermsDocument

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.spacing24) {
                    ForEach(document.articles, id: \.heading) { article in
                        VStack(alignment: .leading, spacing: Spacing.spacing8) {
                            Text(article.heading)
                                .font(Typography.bodyMdSemibold)
                                .foregroundStyle(Colors.textPrimary)

                            Text(article.body)
                                .font(Typography.bodyMdRegular)
                                .foregroundStyle(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, Spacing.spacing20)
                .padding(.top, Spacing.spacing24)
                .padding(.bottom, Spacing.spacing40)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var topNavigationBar: some View {
        ZStack {
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

            Text(document.title)
                .font(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)
        }
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }
}

#Preview {
    TermsFullTextView(document: .serviceTerms)
}
