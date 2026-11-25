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

// 탭 바 안에서 각 탭이 실제로 차지하는 프레임. 탭 밑줄을 matchedGeometryEffect 없이
// 직접 측정한 위치·너비로 그려서, 스크롤 중 조건부 렌더링이 섞일 때 생기는 튐을 없앤다.
private struct TabFrameKey: PreferenceKey {
    static var defaultValue: [HomeMenuViewModel.Section: CGRect] = [:]
    static func reduce(value: inout [HomeMenuViewModel.Section: CGRect], nextValue: () -> [HomeMenuViewModel.Section: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// 탭 줄 전체(스크롤되는 콘텐츠)의, 탭 바 자신을 기준으로 한 프레임. 왼쪽/오른쪽
// 페이드 마스크를 실제로 더 스크롤할 내용이 있는 쪽에만 보이게 하는 데 쓴다.
private struct TabsContentFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// 탭 바(뷰포트) 자체의 너비. 스크롤 콘텐츠 프레임과 비교해 오른쪽 끝에 닿았는지 판단한다.
private struct TabsViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 각 섹션 전체의 높이(첫 카드만이 아니라). 마지막 섹션이 리스트 뷰포트보다 짧을 때
// 하단 여백을 얼마나 둬야 "탭 바로 아래"까지 스크롤할 수 있는지 계산하는 데 쓴다.
private struct SectionHeightKey: PreferenceKey {
    static var defaultValue: [HomeMenuViewModel.Section: CGFloat] = [:]
    static func reduce(value: inout [HomeMenuViewModel.Section: CGFloat], nextValue: () -> [HomeMenuViewModel.Section: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// 리스트 맨 아래 유의사항 섹션 자체의 높이. bottomInset보다 짧으면 그 차이만큼만
// 빈 공간을 추가로 둔다.
private struct NoticeHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 메뉴 리스트 위에 떠 있는 하단 바(장바구니 바·실시간 주문 바)의 높이. 0이면 아무것도
// 떠 있지 않다는 뜻이다.
private struct BottomOverlayBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeMenuView: View {
    // 다음 카테고리로 하이라이트가 넘어가기까지, 그 카테고리 메뉴가 이 정도(개수) 보여야 한다.
    private static let sectionActivationItemCount: CGFloat = 1.3
    // 탭 밑줄·탭 줄 스크롤에 쓰는 애니메이션(150~250ms 범위의 ease-out).
    // easeOut은 초반에 이동이 몰려 있어 빠르게(0.2초) 재생하면 "스냅됐다가 슬쩍 더 간다"는
    // 느낌을 준다. easeInOut으로 바꿔 가속·감속이 고르게 보이도록 했다.
    private static let indicatorAnimation = Animation.easeInOut(duration: 0.22)
    // 메뉴 리스트를 탭 섹션으로 스크롤할 때 쓰는 애니메이션(250~350ms 범위의 ease-in-out).
    private static let listScrollAnimation = Animation.easeInOut(duration: 0.3)
    // 이 거리(화면 높이의 배수)를 넘는 스크롤은 먼저 애니메이션 없이 목표 근처까지 점프한 뒤,
    // 마지막 구간만 애니메이션해서 과도하게 긴 스크롤이 "순간이동"처럼 보이지 않게 한다.
    private static let longScrollJumpThresholdInViewports: CGFloat = 2

    @State private var viewModel: HomeMenuViewModel
    @State private var sectionTopOffsets: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var sectionFirstItemHeights: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var sectionHeights: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var tabFrames: [HomeMenuViewModel.Section: CGRect] = [:]
    @State private var tabsContentFrame: CGRect = .zero
    @State private var tabsViewportWidth: CGFloat = 0
    @State private var listViewportHeight: CGFloat = 0
    @State private var bottomOverlayBarHeight: CGFloat = 0
    @State private var noticeHeight: CGFloat = 0
    @State private var scrollSpyDebounceToken = 0
    @State private var router = HomeRouter()
    @State private var cart = CartStore()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onLogout: (String?) -> Void = { _ in }

    // Reduce Motion이 켜져 있으면 nil(=애니메이션 없이 즉시 반영)을 돌려준다.
    private func anim(_ base: Animation) -> Animation? {
        reduceMotion ? nil : base
    }

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
                            searchableMenuItems: searchableMenuItems,
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
                        OrderDetailView(pickupNumber: pickupNumber, storeName: storeName, cart: cart)
                    case .orderDetailHistory(let order):
                        OrderDetailView(order: order, cart: cart)
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

            Group {
                if let liveOrder = viewModel.liveOrder {
                    LiveOrderBarView(order: liveOrder, action: liveOrderTapped)
                        .padding(.horizontal, Spacing.spacing16)
                        .padding(.bottom, Spacing.spacing8)
                } else if !cart.isEmpty {
                    cartBar
                } else {
                    Color.clear.frame(height: 0)
                }
            }
            // 이 바의 실제 높이를 재서, 메뉴 리스트 하단 여백(bottomInset) 계산에 반영한다.
            // 떠 있는 바가 없으면 0이 보고된다.
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: BottomOverlayBarHeightKey.self, value: geometry.size.height)
                }
            )
            .onPreferenceChange(BottomOverlayBarHeightKey.self) { bottomOverlayBarHeight = $0 }

            if viewModel.isCartSnackbarVisible {
                cartSnackbar
                    // Figma 스펙: Snackbar는 하단 CTA 위 spacing-16.
                    // cartBar 높이 56 + 자체 하단 패딩 8 + 여기 16 = 80.
                    .padding(.bottom, cart.isEmpty ? Spacing.spacing16 : 80)
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
                    .typography(Typography.bodyLgSemibold)
                    .foregroundStyle(Colors.textOnFill)

                Text("\(cart.totalQuantity)")
                    .typography(Typography.bodySmBold)
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
                .typography(Typography.bodyMdSemibold)
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
            // .background(GeometryReader{...})를 ScrollView에 붙이는 방식은 이 화면에서
            // 뷰포트 크기를 0으로 보고하는 경우가 있었다(레이아웃 해석 순서 문제로 추정).
            // GeometryReader를 ScrollView의 직계 부모로 직접 감싸면 제안받은 크기를
            // 그대로 읽어서 훨씬 안정적으로 측정된다.
            GeometryReader { listGeometry in
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            // LazyVStack을 쓰면 아직 스크롤로 지나간 적 없는 섹션(예: 맨 아래 "음료")의
                            // GeometryReader가 렌더되지 않아 높이·오프셋이 비어 있는 채로 남는다.
                            // 그 상태에서 하단 여백(bottomInset)·긴 거리 사전 점프(sectionBeforeTarget)
                            // 계산이 그 섹션을 한 번도 안 본 상태로는 틀어져, 처음 탭했을 때 리스트가
                            // 안 움직이거나 중간 점프가 생략되는 버그로 이어졌다. 메뉴 항목 수가
                            // 적어(총 10여 개) 레이지 로딩이 꼭 필요하지 않으므로 일반 VStack으로 바꿔
                            // 모든 섹션의 지오메트리가 처음부터 안정적으로 잡히게 한다.
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.sections.enumerated()), id: \.element) { index, section in
                                    // 디바이더는 탭 스크롤 앵커(.id) 밖에 둔다. 탭을 눌렀을 때 디바이더가
                                    // 화면 맨 위에 걸치는 게 아니라, 그 아래 메뉴 내용이 바로 보여야 한다.
                                    if index > 0 {
                                        thickDivider
                                    }
                                    sectionView(section)
                                        .id(section)
                                        .background(
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .preference(
                                                        key: SectionTopOffsetKey.self,
                                                        value: [section: geometry.frame(in: .named("menuScroll")).minY]
                                                    )
                                                    .preference(
                                                        key: SectionHeightKey.self,
                                                        value: [section: geometry.size.height]
                                                    )
                                            }
                                        )
                                }

                                // 마지막 섹션이 리스트 뷰포트보다 짧아도 탭 바로 아래까지 스크롤할 수
                                // 있도록, 유의사항 영역 전체를 유의사항 자체 높이의 2배로 고정해 둔다
                                // (bottomInset이 그보다 크게 필요한 경우에만 그만큼 더 늘어난다).
                                // 이 영역은 끝까지 흰 여백 없이 전부 회색(backgroundLower)으로 통일한다.
                                noticeSection
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear.preference(key: NoticeHeightKey.self, value: geometry.size.height)
                                        }
                                    )
                                    .frame(minHeight: max(noticeHeight * 2, bottomInset), alignment: .top)
                                    .background(Colors.backgroundLower)
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
                        .onPreferenceChange(SectionHeightKey.self) { sectionHeights = $0 }
                        .onPreferenceChange(NoticeHeightKey.self) { noticeHeight = $0 }
                        // 사용자가 리스트를 직접 드래그하기 시작하면, 탭 클릭으로 시작된 프로그램
                        // 스크롤이 아직 "끝났다고 확정"되지 않았더라도 즉시 scroll-spy로 돌아간다.
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { _ in viewModel.userDidStartDragging() }
                        )
                        .onChange(of: viewModel.scrollTarget) {
                            guard let section = viewModel.scrollTarget else { return }
                            scrollToSection(section, proxy: proxy)
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
                .onAppear { listViewportHeight = listGeometry.size.height }
                .onChange(of: listGeometry.size.height) { _, newValue in listViewportHeight = newValue }
            }
        }
    }

    // 마지막 섹션이 리스트 뷰포트보다 짧을 때만, 그 차이만큼 하단 여백을 둔다.
    // 뷰포트 높이에서 장바구니 바 등 떠 있는 오버레이의 높이를 먼저 뺀 뒤 계산한다.
    private var bottomInset: CGFloat {
        guard let last = viewModel.sections.last, let lastHeight = sectionHeights[last] else { return 0 }
        let effectiveViewportHeight = max(listViewportHeight - bottomOverlayBarHeight, 0)
        return max(effectiveViewportHeight - lastHeight, 0)
    }

    // 탭을 눌렀을 때 리스트를 해당 섹션으로 스크롤한다. 이동 거리가 뷰포트의
    // longScrollJumpThresholdInViewports배를 넘으면, 먼저 애니메이션 없이 목표 근처(한 화면
    // 앞) 섹션까지 점프한 뒤 마지막 구간만 애니메이션해서 과도하게 긴 스크롤이 "순간이동"처럼
    // 보이지 않게 한다.
    //
    // withAnimation(completion:)은 ScrollViewReader.scrollTo에는 믿을 수 없다 — 디버그로 실측한
    // 결과, 실제 스크롤(수백 ms)이 끝나기 전인 수십 ms 안에 콜백이 먼저 불려서
    // isProgrammaticScrollInProgress가 너무 일찍 꺼졌다. 그 틈에 scroll-spy가 깨어나 리스트가
    // 아직 스크롤되는 중간중간의 섹션들을 "현재"로 잘못 인식해, 탭 하이라이트와 탭 줄 스크롤이
    // 0.3초 안에 몇 번씩 다른 목표로 다시 튀면서 좌우로 떠는 것처럼 보였다(issue였던 "드르륵").
    // 그래서 완료 콜백은 아예 쓰지 않고, ViewModel의 600ms 타임아웃 하나로만 플래그를 끈다 —
    // 실제 스크롤(최대 0.3초 + 긴 점프 시 조금 더)보다 넉넉히 길어서 항상 다 끝난 뒤에 풀린다.
    private func scrollToSection(_ target: HomeMenuViewModel.Section, proxy: ScrollViewProxy) {
        guard !reduceMotion else {
            proxy.scrollTo(target, anchor: .top)
            viewModel.programmaticScrollDidFinish()
            return
        }

        let distance = abs(sectionTopOffsets[target] ?? 0)
        if listViewportHeight > 0,
           distance > listViewportHeight * Self.longScrollJumpThresholdInViewports,
           let nearSection = sectionBeforeTarget(target, atLeast: listViewportHeight) {
            var jumpTransaction = Transaction()
            jumpTransaction.disablesAnimations = true
            withTransaction(jumpTransaction) {
                proxy.scrollTo(nearSection, anchor: .top)
            }
        }

        withAnimation(Self.listScrollAnimation) {
            proxy.scrollTo(target, anchor: .top)
        }
    }

    // target으로 가는 길목에서, 현재 위치로부터 최소 minDistance만큼 떨어져 있으면서 target에는
    // 가장 가까운 섹션을 찾는다(애니메이션 없이 먼저 점프할 중간 착지 지점).
    private func sectionBeforeTarget(_ target: HomeMenuViewModel.Section, atLeast minDistance: CGFloat) -> HomeMenuViewModel.Section? {
        guard let targetOffset = sectionTopOffsets[target],
              let targetIndex = viewModel.sections.firstIndex(of: target) else { return nil }

        // 양수면 목표가 아래쪽(스크롤 다운), 음수면 위쪽(스크롤 업)에 있다.
        let candidates = targetOffset >= 0
            ? viewModel.sections[..<targetIndex]
            : viewModel.sections[(targetIndex + 1)...]

        return candidates
            .compactMap { section -> (HomeMenuViewModel.Section, CGFloat)? in
                guard let offset = sectionTopOffsets[section] else { return nil }
                let distanceFromTarget = abs(offset - targetOffset)
                guard distanceFromTarget >= minDistance else { return nil }
                return (section, distanceFromTarget)
            }
            .min { $0.1 < $1.1 }?
            .0
    }

    private func unavailableNoticeBanner(_ message: String) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Image(.calloutInfoIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text(message)
                .typography(Typography.bodySmSemibold)
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
                        .typography(Typography.bodyXlSemibold)
                        .foregroundStyle(Colors.textPrimary)
                        .lineLimit(1)

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
                    // 탭 줄 양 끝에 최소 16pt를 둬서, 마지막 탭도 스크롤로 중앙까지 끌어올 여지를 준다.
                    .padding(.horizontal, Spacing.spacing16)
                    .coordinateSpace(name: "tabsRow")
                    // Figma: Indicator는 탭 바닥(bottom-0)에 틈 없이 붙고, 좌우 12px은 탭 자체 패딩과 같다.
                    // 두께는 사용자 요청으로 Figma 원본 2px의 1.5배인 3px을 쓴다.
                    // matchedGeometryEffect는 스크롤 중 조건부 렌더링과 섞이면 다른 탭으로 튀어 보이는
                    // 버그가 있어, 각 탭의 실측 프레임을 직접 추적해 하나의 밑줄만 위치·너비를 옮긴다.
                    .overlay(alignment: .bottomLeading) {
                        if let section = viewModel.selectedSection, let frame = tabFrames[section] {
                            Capsule()
                                .fill(Colors.textPrimary)
                                .frame(width: max(frame.width - Spacing.spacing12 * 2, 0), height: 3)
                                .offset(x: frame.minX + Spacing.spacing12)
                                // 밑줄의 위치·너비만 여기서 따로 애니메이션한다(라벨 폰트 교체는
                                // 즉시 반영돼야 가변 폰트 보간으로 인한 깜빡임이 없다). section이
                                // 아니라 frame 값 자체를 기준으로 걸어서, 탭 전환이 아니더라도
                                // 프레임이 바뀌면(측정 잡음 포함) 스냅 없이 항상 부드럽게 보간한다.
                                .animation(anim(Self.indicatorAnimation), value: frame)
                        }
                    }
                    // 가로 스크롤 중에는 같은 탭이라도 GeometryReader가 미세하게(소수점 단위로)
                    // 다른 값을 계속 보고해서, 그 값을 그대로 밑줄에 쓰면 좌우로 떨리는 것처럼
                    // 보였다. 정수 pt로 반올림해 그 잡음을 걸러낸다.
                    .onPreferenceChange(TabFrameKey.self) { newFrames in
                        tabFrames = newFrames.mapValues {
                            CGRect(x: $0.minX.rounded(), y: $0.minY.rounded(), width: $0.width.rounded(), height: $0.height.rounded())
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: TabsContentFrameKey.self,
                                value: geometry.frame(in: .named("tabsViewport"))
                            )
                        }
                    )
                }
                .coordinateSpace(name: "tabsViewport")
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: TabsViewportWidthKey.self, value: geometry.size.width)
                    }
                )
                .onPreferenceChange(TabsContentFrameKey.self) { tabsContentFrame = $0 }
                .onPreferenceChange(TabsViewportWidthKey.self) { tabsViewportWidth = $0 }
                .onChange(of: viewModel.selectedSection) {
                    guard let section = viewModel.selectedSection else { return }
                    withAnimation(anim(Self.indicatorAnimation)) {
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
                .opacity(isTabsLeadingFadeVisible ? 1 : 0)

                Spacer(minLength: 0)

                LinearGradient(
                    colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: Spacing.spacing40)
                .opacity(isTabsTrailingFadeVisible ? 1 : 0)
            }
            .animation(anim(.easeOut(duration: 0.15)), value: isTabsLeadingFadeVisible)
            .animation(anim(.easeOut(duration: 0.15)), value: isTabsTrailingFadeVisible)
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

    // 탭 줄을 왼쪽으로 더 스크롤할 내용이 남아 있을 때만 왼쪽 페이드를 보여준다.
    private var isTabsLeadingFadeVisible: Bool {
        tabsContentFrame.minX < -1
    }

    // 탭 줄을 오른쪽으로 더 스크롤할 내용이 남아 있을 때만 오른쪽 페이드를 보여준다.
    private var isTabsTrailingFadeVisible: Bool {
        tabsContentFrame.maxX > tabsViewportWidth + 1
    }

    private func tabButton(_ section: HomeMenuViewModel.Section) -> some View {
        let isSelected = viewModel.selectedSection == section
        let title = viewModel.sectionTitle(section)

        return Button(action: {
            // selectSection 자체는 애니메이션 없이 즉시 반영한다. 라벨 굵기는 바로 바뀌고,
            // 밑줄만 아래 .animation(value:)로 따로 슬라이드시킨다 — 라벨까지 같은 트랜잭션에
            // 묶으면 가변 폰트 굵기 보간과 맞물려 깜빡일 여지가 있어 방어적으로 분리해 둔다.
            viewModel.selectSection(section)
        }) {
            ZStack {
                // 보이지 않지만 항상 Bold 폭으로 레이아웃을 고정한다. 선택 시 폰트가 Bold로
                // 바뀌면서 탭 너비(= 밑줄 좌표 기준)가 흔들려, 밑줄이 전환 도중 잘못된
                // 위치로 스냅되던 문제의 원인이었다.
                Text(title)
                    .typography(Typography.bodyLgBold)
                    .opacity(0)
                    .accessibilityHidden(true)

                Text(title)
                    .typography(isSelected ? Typography.bodyLgBold : Typography.bodyLgSemibold)
                    .foregroundStyle(isSelected ? Colors.textPrimary : Colors.textTertiary)
                    .animation(nil, value: isSelected)
            }
            .padding(.horizontal, Spacing.spacing12)
            .frame(height: 51)
        }
        .buttonStyle(.plain)
        .transaction { $0.animation = nil }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: TabFrameKey.self,
                    value: [section: geometry.frame(in: .named("tabsRow"))]
                )
            }
        )
    }

    private func sectionView(_ section: HomeMenuViewModel.Section) -> some View {
        VStack(spacing: 0) {
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
    private func currentSectionFromScrollPosition() -> HomeMenuViewModel.Section? {
        sectionTopOffsets
            .filter { section, minY in
                let itemHeight = sectionFirstItemHeights[section] ?? 0
                return minY - itemHeight * Self.sectionActivationItemCount <= 0
            }
            .max { $0.value < $1.value }?
            .key
            ?? viewModel.sections.first
    }

    // 탭 클릭으로 시작한 프로그램 스크롤이 (타임아웃이나 드래그 시작으로) 보호가 풀린 직후에도
    // 관성으로 몇 프레임 더 움직이는 경우가 있다. 그 몇 프레임 동안 onPreferenceChange가 연달아
    // 여러 섹션을 "현재"로 보고하면, 보호가 풀리자마자 그 중간 섹션들로 탭이 순간적으로
    // 전부 튀어 보인다(실측 확인 — 드래그 직후 한 탭 틱 사이에 5개 섹션을 연쇄적으로 거침).
    // 여기서 매번 바로 반영하지 않고 짧게(80ms) 묶어서, 그 사이 또 바뀌면 타이머를 다시
    // 시작한다 — 연쇄가 멈추고 실제로 자리 잡은 마지막 섹션 하나만 반영된다. 정상적인 손가락
    // 스크롤은 계속 새 값을 보고하므로 체감 지연이 없고, 멈췄을 때만 이 지연이 적용된다.
    private static let scrollSpySettleDelay: Duration = .milliseconds(80)

    private func updateCurrentSectionFromScroll() {
        guard let current = currentSectionFromScrollPosition() else { return }
        scrollSpyDebounceToken += 1
        let token = scrollSpyDebounceToken
        Task {
            try? await Task.sleep(for: Self.scrollSpySettleDelay)
            guard token == scrollSpyDebounceToken else { return }
            viewModel.updateSelectedSectionFromScroll(current)
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
            .typography(Typography.bodyLgBold)
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
                            .typography(Typography.bodyLgSemibold)
                            .foregroundStyle(Colors.textPrimary)
                        Text("\(item.price.formatted())원")
                            .typography(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textPrimary)
                    }
                }

                Text(item.description)
                    .typography(Typography.bodySmRegular)
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
                .typography(Typography.bodyXsMedium)
                .foregroundStyle(Colors.textSecondary)
                .padding(.horizontal, Spacing.spacing8)
                .frame(height: 24)
                .background(Colors.fillNeutralWeak)
                .clipShape(Capsule())
        } else if let badge = item.badge {
            Text(badge == .popular ? "인기" : "신규")
                .typography(Typography.bodyXsBold)
                .foregroundStyle(Colors.textOnFill)
                .padding(.horizontal, Spacing.spacing8)
                .frame(height: 24)
                .background(badge == .popular ? Colors.fillBrand : Colors.fillSuccess)
                .clipShape(Capsule())
        }
    }

    // 메뉴 리스트 맨 아래, 더 이상 메뉴가 없는 구간을 빈 흰 공백으로 두지 않고 유의사항으로
    // 채운다. 제목 1줄 + 글머리 기호 4개 자리를 만들어 뒀으니, 실제 문구는 Xcode에서
    // noticeBulletPoints 배열만 바꾸면 된다.
    private static let noticeBulletPoints = [
        "유의사항 1을 입력해 주세요",
        "유의사항 2를 입력해 주세요",
        "유의사항 3을 입력해 주세요",
        "유의사항 4를 입력해 주세요"
    ]

    private var noticeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing12) {
            Text("유의사항")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)

            VStack(alignment: .leading, spacing: Spacing.spacing8) {
                ForEach(Array(Self.noticeBulletPoints.enumerated()), id: \.offset) { _, text in
                    noticeBulletRow(text)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.spacing20)
        .background(Colors.backgroundLower)
    }

    private func noticeBulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.spacing8) {
            Text("•")
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)

            Text(text)
                .typography(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
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
    // 중복으로 들어있을 수 있어 id 기준으로 한 번만 남긴다. (메뉴 이름은 서로 다른 메뉴끼리도
    // 겹칠 수 있어 이름으로 거르면 인기 메뉴 등 실제로는 다른 항목이 사라진다.)
    private var searchableMenuItems: [MenuItem] {
        var seenIDs = Set<String>()
        var result: [MenuItem] = []
        for item in viewModel.recentOrders + viewModel.categories.flatMap(\.items) {
            guard seenIDs.insert(item.id).inserted else { continue }
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
