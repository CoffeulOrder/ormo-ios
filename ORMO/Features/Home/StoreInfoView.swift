import SwiftUI

struct StoreInfoView: View {
    @Environment(\.dismiss) private var dismiss
    let store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                storeTitleRow
                section(title: "위치") {
                    Text(store.location)
                        .typography(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                section(title: "운영시간") {
                    VStack(alignment: .leading, spacing: Spacing.spacing8) {
                        infoRow(label: "월~금", value: store.operatingHours.weekdays)
                        infoRow(label: "토", value: store.operatingHours.saturday)
                        infoRow(label: "일·공휴일", value: store.operatingHours.sundayAndHoliday)
                    }
                }
                if let notice = store.notice {
                    section(title: "공지") {
                        Text(hangulWrapping: notice)
                            .typography(Typography.bodyMdRegular)
                            .foregroundStyle(Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Rectangle()
                    .fill(Colors.backgroundLower)
                    .frame(height: 12)
                    .padding(.top, Spacing.spacing12)

                section(title: "판매자 정보") {
                    VStack(alignment: .leading, spacing: Spacing.spacing12) {
                        sellerInfoRow(label: "상호", value: store.sellerInfo.businessName)
                        sellerInfoRow(label: "대표자", value: store.sellerInfo.representative)
                        sellerInfoRow(label: "사업자등록번호", value: store.sellerInfo.registrationNumber)
                        sellerInfoRow(label: "주소", value: store.sellerInfo.address)
                        sellerInfoRow(label: "연락처", value: store.sellerInfo.phoneNumber)
                        sellerInfoRow(label: "통신판매업 신고번호", value: store.sellerInfo.mailOrderNumber)
                    }
                }

                disclaimerBox
                    .padding(.horizontal, Spacing.spacing20)
                    .padding(.top, Spacing.spacing8)
            }
            .padding(.bottom, Spacing.spacing24)
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .safeAreaInset(edge: .top, spacing: 0) {
            topNavigationBar
        }
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

            Text("매장 정보")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)
        }
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var storeTitleRow: some View {
        HStack(spacing: Spacing.spacing8) {
            Text(store.name)
                .typography(Typography.bodyXlBold)
                .foregroundStyle(Colors.textStrong)

            if store.status != .closed {
                Text(statusBadgeText)
                    .typography(Typography.bodyXsMedium)
                    .foregroundStyle(store.status == .open ? Colors.textBrand : Colors.textWarning)
                    .padding(.horizontal, Spacing.spacing8)
                    .frame(height: 24)
                    .background(store.status == .open ? Colors.fillBrandWeak : Colors.fillWarningWeak)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing8)
    }

    private var statusBadgeText: String {
        switch store.status {
        case .open: "영업 중"
        case .paused(let resumesAtText): "잠시 쉬어요 · \(resumesAtText) 재개"
        case .closed: ""
        }
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing8) {
            Text(title)
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
            content()
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing16) {
            Text(label)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
                .fixedSize()
            Text(hangulWrapping: value)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func sellerInfoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing16) {
            Text(label)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
                .frame(width: 144, alignment: .leading)
            Text(hangulWrapping: value)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var disclaimerBox: some View {
        Text("ORMO는 통신판매중개자로 주문과 결제를 중개해요. 음료와 환불에 대한 책임은 판매자에게 있어요.")
            .typography(Typography.bodySmRegular)
            .foregroundStyle(Colors.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.spacing16)
            .padding(.vertical, Spacing.spacing12)
            .background(Colors.backgroundLower)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}

#Preview {
    StoreInfoView(
        store: Store(
            id: "preview",
            name: "을지대학교 범석관 카페",
            status: .open,
            address: "경기도 성남시 수정구 상성대로 567번길 1층 일부호(양지동)",
            distanceText: "910m",
            walkTimeText: "14분",
            location: "범석관 1층 로비",
            operatingHours: OperatingHours(weekdays: "08:30~18:00", saturday: "10:00~15:00", sundayAndHoliday: "쉬어요"),
            notice: "11월 20일(목)은 학교 행사로 14:00까지만 열어요",
            sellerInfo: SellerInfo(
                businessName: "을지대학교 범석관 카페",
                representative: "김오르",
                registrationNumber: "123-45-67890",
                address: "경기도 성남시 수정구 산성대로 567번길 1층 (양지동)",
                phoneNumber: "031-000-0000",
                mailOrderNumber: "준비 중"
            )
        )
    )
}
