import SwiftUI

// 스크롤 중 각 섹션의 맨 위 Y좌표를 모아, 현재 화면에 들어온 섹션을 추적한다.
private struct SectionTopOffsetKey: PreferenceKey {
    static var defaultValue: [HomeMenuViewModel.Section: CGFloat] = [:]
    static func reduce(value: inout [HomeMenuViewModel.Section: CGFloat], nextValue: () -> [HomeMenuViewModel.Section: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// 각 섹션 첫 메뉴 카드의 높이. "메뉴 1.3개 정도" 기준으로 하이라이트 전환 시점을 늦추는 데 쓴다.
private struct SectionFirstItemHeightKey: PreferenceKey {
    static var defaultValue: [HomeMenuViewModel.Section: CGFloat] = [:]
    static func reduce(value: inout [HomeMenuViewModel.Section: CGFloat], nextValue: () -> [HomeMenuViewModel.Section: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct HomeMenuView: View {
    // 다음 카테고리로 하이라이트가 넘어가기까지, 그 카테고리 메뉴가 이 정도(개수) 보여야 한다.
    private static let sectionActivationItemCount: CGFloat = 1.3

    @State private var viewModel = HomeMenuViewModel()
    @State private var sectionTopOffsets: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var sectionFirstItemHeights: [HomeMenuViewModel.Section: CGFloat] = [:]

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if !viewModel.sections.isEmpty {
                tabsBar
            }
            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.sections.enumerated()), id: \.element) { index, section in
                                sectionView(section, isFirst: index == 0)
                                    .id(section)
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear.preference(
                                                key: SectionTopOffsetKey.self,
                                                value: [section: geometry.frame(in: .named("menuScroll")).minY]
                                            )
                                        }
                                    )
                            }
                        }
                    }
                    .coordinateSpace(name: "menuScroll")
                    .onPreferenceChange(SectionTopOffsetKey.self) { offsets in
                        sectionTopOffsets = offsets
                        updateCurrentSectionFromScroll()
                    }
                    .onPreferenceChange(SectionFirstItemHeightKey.self) { heights in
                        sectionFirstItemHeights = heights
                        updateCurrentSectionFromScroll()
                    }
                    .onChange(of: viewModel.scrollTarget) {
                        guard let section = viewModel.scrollTarget else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(section, anchor: .top)
                        }
                    }
                }

                LinearGradient(
                    colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Spacing.spacing40)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: storeSelectionTapped) {
                HStack(spacing: Spacing.spacing8) {
                    Text(viewModel.storeName)
                        .font(Typography.bodyXlSemibold)
                        .foregroundStyle(Colors.textPrimary)

                    Image(.chevronDown)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: searchTapped) {
                Image(.searchIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Button(action: myPageTapped) {
                Image(.userIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing8)
        .background(Colors.backgroundDefault)
    }

    private var tabsBar: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(viewModel.sections, id: \.self) { section in
                            tabButton(section)
                                .id(section)
                        }
                    }
                    .padding(.horizontal, Spacing.spacing20)
                }
                .onChange(of: viewModel.selectedSection) {
                    guard let section = viewModel.selectedSection else { return }
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(section, anchor: .center)
                    }
                }
            }

            HStack(spacing: 0) {
                LinearGradient(
                    colors: [Colors.backgroundDefault, Colors.backgroundDefault.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: Spacing.spacing40)

                Spacer(minLength: 0)

                LinearGradient(
                    colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: Spacing.spacing40)
            }
            .allowsHitTesting(false)
        }
        .frame(height: 51)
        .background(Colors.backgroundDefault)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Colors.borderDefault)
                .frame(height: 1)
        }
    }

    private func tabButton(_ section: HomeMenuViewModel.Section) -> some View {
        let isSelected = viewModel.selectedSection == section

        return Button(action: { viewModel.selectSection(section) }) {
            Text(viewModel.sectionTitle(section))
                .font(isSelected ? Typography.bodyLgBold : Typography.bodyLgSemibold)
                .foregroundStyle(isSelected ? Colors.textPrimary : Colors.textTertiary)
                .overlay(alignment: .bottom) {
                    if isSelected {
                        Capsule()
                            .fill(Colors.textPrimary)
                            .frame(height: 2)
                            .offset(y: 8)
                    }
                }
                .padding(.horizontal, Spacing.spacing12)
                .frame(height: 51)
        }
        .buttonStyle(.plain)
    }

    private func sectionView(_ section: HomeMenuViewModel.Section, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            if !isFirst {
                thickDivider
            }

            if case .category = section {
                categoryLabel(viewModel.sectionTitle(section))
            }

            let items = menuItems(for: section)
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    thinDivider
                }
                if index == 0 {
                    menuCard(item)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: SectionFirstItemHeightKey.self,
                                    value: [section: geometry.size.height]
                                )
                            }
                        )
                } else {
                    menuCard(item)
                }
            }
        }
    }

    // "메뉴 1.3개 정도" 보일 때 다음 섹션으로 하이라이트를 넘긴다: 섹션 상단이 화면 위로
    // (첫 카드 높이 × 1.3)만큼 더 지나가야 그 섹션을 "현재"로 인정한다.
    private func updateCurrentSectionFromScroll() {
        let current = sectionTopOffsets
            .filter { section, minY in
                let itemHeight = sectionFirstItemHeights[section] ?? 0
                return minY - itemHeight * Self.sectionActivationItemCount <= 0
            }
            .max { $0.value < $1.value }?
            .key
        if let current {
            viewModel.updateSelectedSectionFromScroll(current)
        } else if let first = viewModel.sections.first {
            viewModel.updateSelectedSectionFromScroll(first)
        }
    }

    private func menuItems(for section: HomeMenuViewModel.Section) -> [MenuItem] {
        switch section {
        case .recentOrders:
            viewModel.recentOrders
        case .category(let id):
            viewModel.categories.first { $0.id == id }?.items ?? []
        }
    }

    private func categoryLabel(_ title: String) -> some View {
        Text(title)
            .font(Typography.bodyLgBold)
            .foregroundStyle(Colors.textPrimary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func menuCard(_ item: MenuItem) -> some View {
        Group {
            if item.isSoldOut {
                menuCardContent(item)
            } else {
                Button(action: { menuItemTapped(item) }) {
                    menuCardContent(item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func menuCardContent(_ item: MenuItem) -> some View {
        HStack(spacing: Spacing.spacing12) {
            VStack(alignment: .leading, spacing: Spacing.spacing12) {
                VStack(alignment: .leading, spacing: Spacing.spacing8) {
                    menuBadge(item)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.name)
                            .font(Typography.bodyLgSemibold)
                            .foregroundStyle(Colors.textPrimary)
                        Text("\(item.price.formatted())원")
                            .font(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textPrimary)
                    }
                }

                Text(item.description)
                    .font(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(item.isSoldOut ? 0.5 : 1)
        .padding(Spacing.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.backgroundDefault)
    }

    @ViewBuilder
    private func menuBadge(_ item: MenuItem) -> some View {
        if item.isSoldOut {
            Text("품절")
                .font(Typography.bodyXsMedium)
                .foregroundStyle(Colors.textSecondary)
                .padding(.horizontal, Spacing.spacing8)
                .frame(height: 24)
                .background(Colors.fillNeutralWeak)
                .clipShape(Capsule())
        } else if let badge = item.badge {
            Text(badge == .popular ? "인기" : "신규")
                .font(Typography.bodyXsBold)
                .foregroundStyle(Colors.textOnFill)
                .padding(.horizontal, Spacing.spacing8)
                .frame(height: 24)
                .background(badge == .popular ? Colors.fillBrand : Colors.fillSuccess)
                .clipShape(Capsule())
        }
    }

    private var thinDivider: some View {
        Rectangle()
            .fill(Colors.borderDefault)
            .frame(height: 1)
    }

    private var thickDivider: some View {
        Rectangle()
            .fill(Colors.backgroundLower)
            .frame(height: 12)
    }

    private func storeSelectionTapped() {
        // TODO: 1.1.1 매장 선택 화면으로 이동
    }

    private func searchTapped() {
        // TODO: 2.1.3 메뉴 검색 화면으로 이동
    }

    private func myPageTapped() {
        // TODO: 5.1.1 내 정보 화면으로 이동
    }

    private func menuItemTapped(_ item: MenuItem) {
        // TODO: 2.2.1 옵션 선택 화면으로 이동
    }
}

#Preview {
    HomeMenuView()
}
