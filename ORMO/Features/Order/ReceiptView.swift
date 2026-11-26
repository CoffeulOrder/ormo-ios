import SwiftUI

// Figma "4.3.6 영수증" — 카드사·사업자 정보는 전부 Mock 고정값이다(실제 결제 연동 전까지는 의미 없는 값).
struct ReceiptView: View {
    @Environment(\.dismiss) private var dismiss
    let pickupNumber: Int
    let storeName: String
    let totalPrice: Int
    let paidAt: Date

    private static let approvalDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                receiptContent
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("영수증")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)

            HStack(spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(.closeIconSolid)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: downloadTapped) {
                    Image(.downloadIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var receiptContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            receiptHeader
                .padding(.bottom, Spacing.spacing24)

            Rectangle()
                .fill(Colors.fillNeutral)
                .frame(height: 2)

            itemTableRow("메뉴명", "단가", "수량", "금액", font: Typography.bodySmMedium, color: Colors.textSecondary)
                .padding(.vertical, Spacing.spacing12)

            thinDivider

            itemsSection
                .padding(.vertical, Spacing.spacing16)

            thinDivider

            totalsSection
                .padding(.vertical, Spacing.spacing16)

            thinDivider

            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                receiptRow("결제 수단", "신용카드")
                receiptRow("카드 번호", "1234-56**-****-7890")
                receiptRow("할부", "일시불")
                receiptRow("승인 번호", "12345678")
                receiptRow("승인 일시", Self.approvalDateFormatter.string(from: paidAt))
            }
            .padding(.vertical, Spacing.spacing16)

            thinDivider

            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                receiptRow("상호", storeName)
                receiptRow("대표자", "홍길동")
                receiptRow("사업자등록번호", "000-00-00000")
                receiptRow("대표 번호", "031-000-0000")
                receiptRow("주소", "경기도 성남시 수정구 상성대로 567번길 1층 일부호(양지동)")
            }
            .padding(.vertical, Spacing.spacing16)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing24)
        .padding(.bottom, Spacing.spacing40)
    }

    private var receiptHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text(storeName)
                .typography(Typography.bodyLgMedium)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: Spacing.spacing4) {
                Text("\(pickupNumber)번 |")
                Text("\(totalPrice.formatted())원")
            }
            .typography(Typography.displayXsSemibold)
            .foregroundStyle(Colors.textPrimary)
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            itemTableRow("아메리카노", "2,500", "1", "2,500", font: Typography.bodyMdRegular, color: Colors.textPrimary, nameFont: Typography.bodyMdSemibold)

            Text("M / ICE")
                .typography(Typography.bodySmRegular)
                .foregroundStyle(Colors.textTertiary)

            itemTableRow("(+) 샷추가", "500", "1", "500", font: Typography.bodySmRegular, color: Colors.textTertiary)
        }
    }

    private func itemTableRow(
        _ name: String,
        _ price: String,
        _ quantity: String,
        _ amount: String,
        font: TypographyStyle,
        color: Color,
        nameFont: TypographyStyle? = nil
    ) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Text(name)
                .typography(nameFont ?? font)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(price)
                .frame(width: 64, alignment: .trailing)
            Text(quantity)
                .frame(width: 36, alignment: .center)
            Text(amount)
                .frame(width: 64, alignment: .trailing)
        }
        .typography(font)
        .foregroundStyle(color)
    }

    private var totalsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            totalRow("주문 금액", "\(totalPrice.formatted())")
            totalRow("할인 금액", "0")
            totalRow("결제 금액", "\(totalPrice.formatted())", font: Typography.bodyMdBold, color: Colors.textPrimary)
                .padding(.top, Spacing.spacing8)
        }
    }

    private func totalRow(_ label: String, _ amount: String, font: TypographyStyle = Typography.bodySmRegular, color: Color = Colors.textSecondary) -> some View {
        HStack(spacing: Spacing.spacing16) {
            Text(label)
            Text(amount)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .typography(font)
        .foregroundStyle(color)
    }

    private func receiptRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing16) {
            Text(label)
                .typography(Typography.bodySmRegular)
                .foregroundStyle(Colors.textTertiary)
                .fixedSize()
            Text(hangulWrapping: value)
                .typography(Typography.bodySmMedium)
                .foregroundStyle(Colors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 188, alignment: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var thinDivider: some View {
        Rectangle()
            .fill(Colors.borderDefault)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private func downloadTapped() {
        // TODO: 영수증 PDF·이미지 저장 (이번 범위 밖)
    }
}

#Preview {
    ReceiptView(pickupNumber: 27, storeName: "범석관 카페", totalPrice: 3000, paidAt: Date())
}
