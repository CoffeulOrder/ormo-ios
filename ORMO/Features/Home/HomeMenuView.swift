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

    @State private var viewModel: HomeMenuViewModel
    @State private var sectionTopOffsets: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var sectionFirstItemHeights: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var router = HomeRouter()
    @State private var cart = CartStore()
    var onLogout: (String?) -> Void = { _ in }

    init(viewModel: HomeMenuViewModel = HomeMenuViewModel(), onLogout: @escaping (String?) -> Void = { _ in }) {
        _viewModel = State(initialValue: viewModel)
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            rootContent
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .storeSelection:
                        StoreSelectionView(onStoreConfirmed: { store in
                            Task { await viewModel.applySelectedStore(store) }
                            router.path = NavigationPath()
                        })
                    case .storeInfo(let store):
                        StoreInfoView(store: store)
                    case .search(let items):
                        MenuSearchView(allItems: items)
                    case .menuOptions(let item):
                        MenuOptionsView(
                            item: item,
                            cart: cart,
                            onAddedToCart: { router.path.removeLast() },
                            onOrderNow: { router.path.append(HomeRoute.cart) }
                        )
                    case .cart:
                        CartView(
                            cart: cart,
                            store: viewModel.currentStore,
                            onOrderUnavailable: { router.path = NavigationPath() }
                        )
                    case .paymentProcessing(_, let method, let total, let storeName):
                        PaymentProcessingView(paymentMethod: method, totalPrice: total, storeName: storeName, cart: cart)
                    case .paymentFailure(_, let method, let total, let storeName):
                        PaymentFailureView(cart: cart, paymentMethod: method, totalPrice: total, storeName: storeName)
                    case .paymentExpired:
                        PaymentExpiredView()
                    case .orderComplete(let pickupNumber, let storeName, let queueCount):
                        OrderCompleteView(pickupNumber: pickupNumber, storeName: storeName, queueCount: queueCount)
                    case .orderDetail(let pickupNumber, let storeName):
                        OrderDetailView(pickupNumber: pickupNumber, storeName: storeName)
                    case .orderDetailHistory(let order):
                        OrderDetailView(order: order)
                    case .receipt(let pickupNumber, let storeName, let totalPrice, let paidAt):
                        ReceiptView(pickupNumber: pickupNumber, storeName: storeName, totalPrice: totalPrice, paidAt: paidAt)
                    case .myInfo:
                        MyInfoView(onLogout: onLogout)
                    case .orderHistory:
                        OrderHistoryView(cart: cart)
                    case .changePassword(let email):
                        ChangePasswordView(email: email, onLogout: onLogout)
                    case .notificationSettings:
                        NotificationSettingsView()
                    case .termsAndPolicy:
                        TermsAndPolicyView()
                    case .termsDocument(let document):
                        TermsFullTextView(document: document)
                    case .withdraw:
                        WithdrawView(onWithdrawn: { onLogout(nil) })
                    }
                }
                .enableSwipeBackGesture()
        }
        .environment(router)
    }

    // 로딩·네트워크 오류·서비스 점검·로그인 만료일 때는 상단 바(매장명·검색·내 정보)조차
    // 보여줄 데이터가 없어 화면 전체를 교체한다. 정상적으로 불러온 뒤에만 content를 보여준다.
    private var rootContent: some View {
        Group {
            switch viewModel.loadState {
            case .loading:
                SkeletonLoadingView()
            case .networkError:
                networkErrorView
            case .serviceUnavailable:
                serviceUnavailableView
            case .sessionExpired:
                SessionExpiredView(onLoginTapped: { onLogout(nil) })
            case .loaded:
                content
            }
        }
        .task {
            await viewModel.loadIfNeeded()
            viewModel.observeLiveOrderIfNeeded()
            LocationPermissionManager.shared.requestAuthorizationIfNeeded()
        }
    }

    private var networkErrorView: some View {
        ResultView(
            icon: .wifiOffIcon,
            title: "인터넷 연결을 확인해주세요",
            message: "연결이 복구되면 다시 불러올게요",
            buttonTitle: "다시 시도",
            action: viewModel.retryLoadTapped
        )
        .padding(.top, 120)
        .background(Colors.backgroundDefault.ignoresSafeArea())
    }

    private var serviceUnavailableView: some View {
        ResultView(
            icon: .buildIcon,
            title: "서비스 이용이 원활하지 않아요",
            message: "잠시 후 다시 시도해주세요",
            buttonTitle: "다시 시도",
            action: viewModel.retryLoadTapped
        )
        .padding(.top, 120)
        .background(Colors.backgroundDefault.ignoresSafeArea())
    }

    private var content: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topBar
                if viewModel.hasNoMenu {
                    emptyMenuResultView
                } else {
                    menuListContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if let liveOrder = viewModel.liveOrder {
                LiveOrderBarView(order: liveOrder, action: liveOrderTapped)
                    .padding(.horizontal, Spacing.spacing16)
                    .padding(.bottom, Spacing.spacing8)
            } else if !cart.isEmpty {
                cartBar
            }

            if viewModel.isCartSnackbarVisible {
                cartSnackbar
                    .padding(.bottom, cart.isEmpty ? Spacing.spacing16 : 104)
                    .transition(.opacity)
            }

            if viewModel.isConnectionUnstable {
                connectionUnstableSnackbar
                    .padding(.top, Spacing.spacing4)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.opacity)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .animation(.easeOut(duration: 0.2), value: viewModel.isCartSnackbarVisible)
        .animation(.easeOut(duration: 0.2), value: viewModel.isConnectionUnstable)
        .onChange(of: cart.justAddedMessage) {
            guard let message = cart.justAddedMessage else { return }
            viewModel.showCartAddedSnackbar(message)
            cart.justAddedMessage = nil
        }
    }

    private var connectionUnstableSnackbar: some View {
        Snackbar(message: "연결이 불안정해요", tone: .critical)
            .frame(maxWidth: .infinity)
    }

    private var cartBar: some View {
        Button(action: cartBarTapped) {
            HStack(spacing: Spacing.spacing8) {
                Text("\(cart.totalPrice.formatted())원 보기")
                    .font(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)

                Text("\(cart.totalQuantity)")
                    .font(Typography.bodySmBold)
                    .foregroundStyle(Colors.textBrand)
                    .padding(.horizontal, Spacing.spacing8)
                    .frame(minWidth: 24)
                    .frame(height: 24)
                    .background(Colors.backgroundDefault)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Colors.fillBrand)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.spacing16)
        .padding(.bottom, Spacing.spacing8)
    }

    private var cartSnackbar: some View {
        HStack(spacing: Spacing.spacing12) {
            Image(.toastSuccessIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text(viewModel.cartSnackbarMessage)
                .font(Typography.bodyMdSemibold)
                .foregroundStyle(Colors.textOnFill)
        }
        .padding(.leading, Spacing.spacing16)
        .padding(.trailing, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutral)
        .clipShape(Capsule())
    }

    private func cartBarTapped() {
        router.path.append(HomeRoute.cart)
    }

    private func liveOrderTapped() {
        guard let liveOrder = viewModel.liveOrder else { return }
        router.path.append(HomeRoute.orderDetail(pickupNumber: liveOrder.pickupNumber, storeName: liveOrder.storeName))
    }

    private var emptyMenuResultView: some View {
        ResultView(
            icon: .coffeeIcon,
            title: "아직 메뉴가 없어요",
            message: "메뉴를 준비하고 있어요",
            buttonTitle: "다른 매장 보기",
            action: { router.path.append(HomeRoute.storeSelection) }
        )
        .padding(.top, 120)
    }

    private var menuListContent: some View {
        VStack(spacing: 0) {
            if !viewModel.sections.isEmpty {
                tabsBar
            }
            if let notice = viewModel.unavailableNotice {
                unavailableNoticeBanner(notice)
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
    }

    private func unavailableNoticeBanner(_ message: String) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Image(.calloutInfoIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text(message)
                .font(Typography.bodySmSemibold)
                .foregroundStyle(Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.spacing16)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutralWeak)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing16)
        .padding(.bottom, Spacing.spacing8)
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

            HStack(spacing: 0) {
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
                    .padding(.leading, Spacing.spacing8)
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
            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                VStack(alignment: .leading, spacing: Spacing.spacing4) {
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
        router.path.append(HomeRoute.storeSelection)
    }

    private func searchTapped() {
        router.path.append(HomeRoute.search(searchableMenuItems))
    }

    // 최근 주문과 카테고리 메뉴를 합쳐서 검색 대상 목록을 만든다. 같은 메뉴가 최근 주문에도
    // 중복으로 들어있을 수 있어 이름 기준으로 한 번만 남긴다.
    private var searchableMenuItems: [MenuItem] {
        var seenNames = Set<String>()
        var result: [MenuItem] = []
        for item in viewModel.recentOrders + viewModel.categories.flatMap(\.items) {
            guard seenNames.insert(item.name).inserted else { continue }
            result.append(item)
        }
        return result
    }

    private func myPageTapped() {
        router.path.append(HomeRoute.myInfo)
    }

    private func menuItemTapped(_ item: MenuItem) {
        router.path.append(HomeRoute.menuOptions(item))
    }
}

#Preview {
    HomeMenuView()
}

#Preview("Network Error") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.loadState = .networkError
        }
}

#Preview("Service Unavailable") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.loadState = .serviceUnavailable
        }
}

#Preview("Connection Unstable") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.isConnectionUnstable = true
        }
}
