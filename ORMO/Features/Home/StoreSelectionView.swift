import SwiftUI

struct StoreSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel = StoreSelectionViewModel()
    @State private var isSheetPresented = false

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
        .navigationBarHidden(true)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.storeForChangeConfirmation) {
            isSheetPresented = viewModel.storeForChangeConfirmation != nil
        }
        .overlay {
            BottomSheetContainer(isPresented: $isSheetPresented, bottomPadding: 0) {
                if let store = viewModel.storeForChangeConfirmation {
                    storeChangeSheetContent(store)
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
                .font(Typography.displayXsSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text(viewModel.campusName)
                .font(Typography.bodyMdMedium)
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
                    HStack(spacing: Spacing.spacing8) {
                        Text(store.name)
                            .font(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textPrimary)
                        Text(store.status == .open ? "영업 중" : "영업 종료")
                            .font(Typography.bodySmMedium)
                            .foregroundStyle(store.status == .open ? Colors.textBrand : Colors.textTertiary)
                    }

                    Text(store.address)
                        .font(Typography.bodySmRegular)
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

    private func metaItem(icon: ImageResource, text: String) -> some View {
        HStack(spacing: Spacing.spacing4) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(text)
                .font(Typography.bodySmRegular)
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
        VStack(spacing: Spacing.spacing20) {
            ZStack {
                Circle().fill(Colors.fillNeutralWeak)
                Image(.alertCircleLargeIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
            .frame(width: 60, height: 60)

            VStack(spacing: Spacing.spacing16) {
                VStack(spacing: Spacing.spacing4) {
                    Text("매장 정보를 불러오지 못했어요")
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textStrong)
                    Text("잠시 후 다시 시도해주세요")
                        .font(Typography.bodyMdRegular)
                        .foregroundStyle(Colors.textSecondary)
                }
                .multilineTextAlignment(.center)

                Button(action: { Task { await viewModel.load() } }) {
                    Text("다시 시도")
                        .font(Typography.bodyMdSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .padding(.horizontal, Spacing.spacing16)
                        .frame(height: 38)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Figma control-radius-38 = 10px (토큰 없음)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.spacing40)
        .padding(.top, Spacing.spacing32)
        .padding(.bottom, Spacing.spacing40)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func storeChangeSheetContent(_ store: Store) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Spacing.spacing8) {
                Text(store.name)
                    .font(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textStrong)

                if store.status == .open {
                    statusBadge
                }

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
                    .font(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textPrimary)
            }
            .padding(.horizontal, Spacing.spacing24)

            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                sheetSectionTitle("운영시간")
                VStack(alignment: .leading, spacing: 10) {
                    operatingHoursRow(day: "월~금", hours: store.operatingHours.weekdays)
                    operatingHoursRow(day: "토", hours: store.operatingHours.saturday)
                    operatingHoursRow(day: "일·공휴일", hours: store.operatingHours.sundayAndHoliday)
                }
                .padding(.top, Spacing.spacing8)
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.top, Spacing.spacing16)

            Group {
                Text("매장을 변경하면 장바구니의 메뉴가 삭제돼요")
                    .font(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textSecondary)
                    .padding(.horizontal, Spacing.spacing16)
                    .padding(.vertical, Spacing.spacing12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Colors.fillWarningWeak)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.top, Spacing.spacing12)

            Button(action: { confirmStoreChange(store) }) {
                Text("주문하기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)
            .padding(.bottom, Spacing.spacing20)
        }
    }

    private var statusBadge: some View {
        Text("영업 중")
            .font(Typography.bodyXsMedium)
            .foregroundStyle(Colors.textBrand)
            .padding(.horizontal, Spacing.spacing8)
            .frame(height: 24)
            .background(Colors.fillBrandWeak)
            .clipShape(Capsule())
    }

    private func sheetSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(Typography.bodyLgSemibold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.top, Spacing.spacing8)
    }

    private func operatingHoursRow(day: String, hours: String) -> some View {
        HStack {
            Text(day)
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
            Spacer()
            Text(hours)
                .font(Typography.bodyMdRegular)
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
