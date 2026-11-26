import SwiftUI

struct StoreSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel = StoreSelectionViewModel()
    @State private var isSheetPresented = false
    // 닫히는 애니메이션이 끝나기 전에 viewModel.storeForChangeConfirmation이 먼저 nil이 되면
    // 시트 안 글자가 배경보다 먼저 사라져 버린다. 화면 쪽에 따로 캐시해 애니메이션이 끝날 때까지
    // 내용을 들고 있는다.
    @State private var sheetStore: Store?

    let onStoreConfirmed: (Store) -> Void

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar

            if viewModel.isLoadFailed {
                errorResultView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.spacing16) {
                        titleView
                        storeListView
                    }
                }
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.storeForChangeConfirmation) {
            guard let store = viewModel.storeForChangeConfirmation else { return }
            sheetStore = store
            withAnimation(BottomSheetMotion.contentAnimation) {
                isSheetPresented = true
            }
        }
        .overlay {
            BottomSheetContainer(isPresented: $isSheetPresented, bottomPadding: 0) {
                // isSheetPresented를 조건으로 써야 닫힐 때 같은 트랜잭션 안에서 .transition이
                // 걸려 배경과 같은 속도로 사라진다. sheetStore는 그 값을 계속 들고 있기 위한 캐시일 뿐이다.
                if isSheetPresented, let sheetStore {
                    storeChangeSheetContent(sheetStore)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: isSheetPresented) {
            if !isSheetPresented {
                viewModel.storeForChangeConfirmation = nil
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
        VStack(alignment: .leading, spacing: Spacing.spacing4) {
            Text("어느 카페에서 주문할까요?")
                .typography(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text(viewModel.campusName)
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, 10) // Figma 원본값이 10px (spacing 토큰 중 일치 항목 없음)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var storeListView: some View {
        VStack(spacing: Spacing.spacing8) {
            ForEach(viewModel.stores) { store in
                storeCard(store)
            }
        }
    }

    private func storeCard(_ store: Store) -> some View {
        Button(action: { viewModel.storeTapped(store) }) {
            HStack(spacing: Spacing.spacing12) {
                VStack(alignment: .leading, spacing: Spacing.spacing12) {
                    // 매장 이름이 길어 2줄로 접히면, 영업 상태 라벨은 줄 사이가 아니라 첫째 줄에
                    // 맞춰 정렬돼야 한다.
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.spacing8) {
                        Text(hangulWrapping: store.name)
                            .typography(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textPrimary)
                        Text(statusText(for: store.status))
                            .typography(Typography.bodySmMedium)
                            .foregroundStyle(statusColor(for: store.status))
                    }

                    Text(store.address)
                        .typography(Typography.bodySmRegular)
                        .foregroundStyle(Colors.textSecondary)

                    HStack(spacing: Spacing.spacing12) {
                        metaItem(icon: .mapPinIcon, text: store.distanceText)
                        metaItem(icon: .shoesIcon, text: store.walkTimeText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(store.status == .closed ? 0.5 : 1)

                storeImagePlaceholder
                    .opacity(store.status == .closed ? 0.5 : 1)
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.backgroundDefault)
        }
        .buttonStyle(.plain)
    }

    // 잠시 쉬어요(브레이크타임)는 영업 종료와 달리 메뉴를 계속 볼 수 있어, 흐리게 처리하지 않는다.
    private func statusText(for status: StoreOperatingStatus) -> String {
        switch status {
        case .open: "영업 중"
        case .paused(let resumesAtText): "잠시 쉬어요 · \(resumesAtText) 재개"
        case .closed: "영업 종료"
        }
    }

    private func statusColor(for status: StoreOperatingStatus) -> Color {
        switch status {
        case .open: Colors.textBrand
        case .paused: Colors.textWarning
        case .closed: Colors.textTertiary
        }
    }

    private func metaItem(icon: ImageResource, text: String) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(text)
                .typography(Typography.bodySmRegular)
                .foregroundStyle(Colors.textTertiary)
        }
    }

    private var storeImagePlaceholder: some View {
        ZStack {
            Colors.fillNeutralWeak
            Image(.imagePlaceholderIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .frame(width: 90, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Colors.borderDefault, lineWidth: 1)
        )
    }

    private var errorResultView: some View {
        ResultView(
            icon: .alertCircleLargeIcon,
            title: "매장 정보를 불러오지 못했어요",
            message: "잠시 후 다시 시도해주세요",
            buttonTitle: "다시 시도",
            action: { Task { await viewModel.load() } }
        )
    }

    private func storeChangeSheetContent(_ store: Store) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 매장 이름이 길어 2줄로 접혀도, 상태 태그는 줄 사이가 아니라 첫째 줄 옆 고정된
            // 자리에 와야 한다.
            HStack(alignment: .firstTextBaseline, spacing: Spacing.spacing8) {
                Text(hangulWrapping: store.name)
                    .typography(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textStrong)

                statusBadge(for: store.status)

                Spacer()

                Button(action: { router.path.append(HomeRoute.storeInfo(store)) }) {
                    Image(.infoIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, Spacing.spacing16)

            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                sheetSectionTitle("위치")
                Text(store.location)
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textPrimary)
            }
            .padding(.horizontal, Spacing.spacing20)

            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                sheetSectionTitle("운영시간")
                VStack(alignment: .leading, spacing: 10) {
                    operatingHoursRow(day: "월~금", hours: store.operatingHours.weekdays)
                    operatingHoursRow(day: "토", hours: store.operatingHours.saturday)
                    operatingHoursRow(day: "일·공휴일", hours: store.operatingHours.sundayAndHoliday)
                }
                .padding(.top, Spacing.spacing8)
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)

            HStack(alignment: .top, spacing: Spacing.spacing8) {
                Image(.calloutWarningIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text("매장을 변경하면 장바구니의 메뉴가 삭제돼요")
                    .typography(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.spacing16)
            .padding(.vertical, Spacing.spacing12)
            .background(Colors.fillWarningWeak)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing12)

            Button(action: { confirmStoreChange(store) }) {
                Text("주문하기")
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)
            .padding(.bottom, Spacing.spacing32)
        }
    }

    private func statusBadge(for status: StoreOperatingStatus) -> some View {
        Text(statusText(for: status))
            .typography(Typography.bodyXsMedium)
            .foregroundStyle(statusBadgeForeground(for: status))
            .padding(.horizontal, Spacing.spacing8)
            .frame(height: 24)
            .background(statusBadgeBackground(for: status))
            .clipShape(Capsule())
    }

    private func statusBadgeForeground(for status: StoreOperatingStatus) -> Color {
        switch status {
        case .open: Colors.textBrand
        case .paused: Colors.textWarning
        case .closed: Colors.textTertiary
        }
    }

    private func statusBadgeBackground(for status: StoreOperatingStatus) -> Color {
        switch status {
        case .open: Colors.fillBrandWeak
        case .paused: Colors.fillWarningWeak
        case .closed: Colors.fillNeutralWeak
        }
    }

    private func sheetSectionTitle(_ title: String) -> some View {
        Text(title)
            .typography(Typography.bodyLgSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.top, Spacing.spacing8)
    }

    private func operatingHoursRow(day: String, hours: String) -> some View {
        HStack {
            Text(day)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
            Spacer()
            Text(hours)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textPrimary)
        }
    }

    private func confirmStoreChange(_ store: Store) {
        isSheetPresented = false
        onStoreConfirmed(store)
    }
}

#Preview {
    StoreSelectionView(onStoreConfirmed: { _ in })
        .environment(HomeRouter())
}
