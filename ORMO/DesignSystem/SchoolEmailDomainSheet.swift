import SwiftUI

struct SchoolEmailDomainSheet: View {
    let domains: [String]
    let selectedDomain: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                Text("학교 이메일을 골라주세요")
                    .font(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textStrong)

                Text("학교에서 받은 메일 주소를 골라요")
                    .font(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textTertiary)
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, Spacing.spacing16)

            VStack(spacing: 0) {
                ForEach(domains, id: \.self) { domain in
                    Button {
                        onSelect(domain)
                    } label: {
                        HStack(spacing: Spacing.spacing8) {
                            Text("@\(domain)")
                                .font(Typography.bodyMdMedium)
                                .foregroundStyle(Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if domain == selectedDomain {
                                Image(.checkIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.spacing16)
            .padding(.horizontal, Spacing.spacing24)
        }
    }
}

#Preview {
    SchoolEmailDomainSheet(
        domains: ["g.eulji.ac.kr", "eulji.ac.kr"],
        selectedDomain: "eulji.ac.kr",
        onSelect: { _ in }
    )
}
