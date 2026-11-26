import SwiftUI

// 스크롤 중 각 섹션의 맨 위 Y좌표를 모아, 현재 화면에 들어온 섹션을 추적한다.
private struct SectionTopOffsetKey: PreferenceKey {
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

// 메뉴 리스트 위에 떠 있는 하단 바(장바구니 바)의 높이. 0이면 아무것도 떠 있지 않다는 뜻이다.
private struct BottomOverlayBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeMenuView: View {
    // 탭 밑줄·탭 줄 스크롤에 쓰는 애니메이션(150~250ms 범위의 ease-out).
    // easeOut은 초반에 이동이 몰려 있어 빠르게(0.2초) 재생하면 "스냅됐다가 슬쩍 더 간다"는
    // 느낌을 준다. easeInOut으로 바꿔 가속·감속이 고르게 보이도록 했다.
    private static let indicatorAnimation = Animation.easeInOut(duration: 0.22)
    // 메뉴 리스트를 탭 섹션으로 스크롤할 때 쓰는 애니메이션(250~350ms 범위의 ease-in-out).
    private static let listScrollAnimation = Animation.easeInOut(duration: 0.3)
    // 이 거리(화면 높이의 배수)를 넘는 스크롤은 먼저 애니메이션 없이 목표 근처까지 점프한 뒤,
    // 마지막 구간만 애니메이션해서 과도하게 긴 스크롤이 "순간이동"처럼 보이지 않게 한다.
    private static let longScrollJumpThresholdInViewports: CGFloat = 2
    // Live Section(상단 실시간 현황) 펼쳐진 높이. Figma "Live Section" 프레임 실측값 —
    // 주문 1건이면 142(1226:47214/47588/47776), 2건 이상이면 158(가로 캐러셀 + 페이지 점,
    // 1226:51988/49033/49284) — 컴포넌트 설명의 134는 바(Bar) 자체 높이고 마스터 컴포넌트 수치다.
    // 스크롤로 완전히 접히는 데 필요한 거리도 이 값과 같다("현황 구역 아랫선이 헤더 아랫선에
    // 닿는 순간" = 정확히 이만큼 스크롤했을 때).
    // 2건 이상(페이지 점)은 점 아래 여백을 14로 키우면서 134+8+8+14=164로 다시 맞췄다 — 이
    // 값을 그대로 안 늘리면 바깥 VStack의 고정 높이+clipped() 때문에 여백이 그대로 잘려 보이지
    // 않는다.
    private static let liveSectionHeightSingle: CGFloat = 142
    private static let liveSectionHeightMulti: CGFloat = 164
    // Live Order Bar 한 장의 높이(Figma 컴포넌트 설명 "높이 134"). 캐러셀 페이지 너비·패널
    // 한 줄 높이로 재사용한다.
    private static let liveOrderBarHeight: CGFloat = 134
    // 헤더의 매장 이름 ↔ Live Order Header 전환 커브. Figma development 주석 그대로
    // (cubic-bezier(0.2, 0.9, 0.25, 1), 0.45초). 동작 줄이기 켜짐이면 0.2초 페이드로 대체한다.
    private static let liveHeaderSwapAnimation = Animation.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.45)
    private static let liveHeaderSwapSlideDistance: CGFloat = 36
    // 헤더 아래 주문 목록 패널 열기/닫기 커브. Figma development 주석 그대로
    // ("패널 높이 0 → 줄 합계, 0.36s / 닫기 0.22s ease-out").
    private static let livePanelOpenAnimation = Animation.easeOut(duration: 0.36)
    private static let livePanelCloseAnimation = Animation.easeOut(duration: 0.22)
    // "3건 이상이면 화면 60%까지, 넘치면 패널 안에서 스크롤."
    private static let livePanelMaxHeightRatio: CGFloat = 0.6

    @State private var viewModel: HomeMenuViewModel
    @State private var sectionTopOffsets: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var sectionHeights: [HomeMenuViewModel.Section: CGFloat] = [:]
    @State private var tabFrames: [HomeMenuViewModel.Section: CGRect] = [:]
    @State private var tabsContentGlobalFrame: CGRect = .zero
    @State private var tabsViewportGlobalFrame: CGRect = .zero
    @State private var listViewportHeight: CGFloat = 0
    @State private var bottomOverlayBarHeight: CGFloat = 0
    @State private var noticeHeight: CGFloat = 0
    @State private var scrollSpyDebounceToken = 0
    // 프로그램 스크롤 보호(isProgrammaticScrollInProgress)가 풀린 시각 + settleWindow.
    // 이 시각 이전이면 아직 관성이 남아있을 수 있는 구간으로 보고 디바운스를 적용한다.
    @State private var programmaticScrollSettleGuardUntil: Date?
    // 0(완전히 펼침) ~ 1(완전히 접힘). Live Section 높이·투명도와 헤더 전환을 이 값 하나로 구동한다.
    @State private var liveSectionCollapseProgress: CGFloat = 0
    // 상단 Live Section의 캐러셀이 지금 몇 번째 주문을 보여주고 있는지(페이지 점 표시용).
    @State private var liveCarouselIndex = 0
    // 헤더 아래 주문 목록 패널이 펼쳐져 있는지(진행 중인 주문이 2건 이상일 때만 의미가 있다).
    @State private var isLivePanelExpanded = false
    // topBar(매장 이름/Live Order Header 줄)의 실제 높이 — 그 바로 아래에 패널을 앉히는 데 쓴다.
    @State private var topBarHeight: CGFloat = 0
    // 화면 본문(content) 컨테이너의 실측 높이 — UIScreen.main.bounds(세이프에리어와 무관한 전역값) 대신
    // topBarHeight와 같은 좌표계(로컬 GeometryReader)로 재서 livePanelHeight 계산에 쓴다.
    @State private var screenHeight: CGFloat = 0
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
                    case .search(let storeId, let items):
                        MenuSearchView(storeId: storeId, allItems: items)
                    case .menuOptions(let storeId, let item):
                        MenuOptionsView(
                            storeId: storeId,
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
                    case .changePassword:
                        ChangePasswordView(onLogout: onLogout)
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

    // 이 두 화면은(networkError·serviceUnavailable) 상단 바까지 전부 교체해 보여줄 게 아무것도
    // 없는 완전한 빈 화면이라, 위쪽에 보이는 헤더가 있다고 가정하는 120pt 오프셋(다른 "목록 비어있음"
    // 화면들의 패턴) 대신 화면 전체 안에서 실제로 세로 가운데에 와야 한다.
    private var networkErrorView: some View {
        ResultView(
            icon: .wifiOffIcon,
            title: "인터넷 연결을 확인해주세요",
            message: "연결이 복구되면 다시 불러올게요",
            buttonTitle: "다시 시도",
            action: viewModel.retryLoadTapped
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Colors.backgroundDefault.ignoresSafeArea())
    }

    private var content: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    topBar
                    liveSection
                }
                // LinearGradient는 크기 제약이 없으면 부모가 제안하는 공간을 끝없이 채우려 든다.
                // 이걸 ZStack의 형제로 두면(이전 버전), 위쪽 VStack(바깥쪽)이 받는 maxHeight: .infinity가
                // 그라데이션까지 전달되어 그라데이션이 화면 전체 높이를 요구하고, 그 바람에 이 블록 전체가
                // 실제 내용(topBar+liveSection)보다 훨씬 커져서 메뉴 리스트가 아래로 크게 밀려났다.
                // .background로 붙이면 그라데이션이 이 VStack의 실측 크기에 맞춰져 이 문제가 없다.
                .background(alignment: .top) {
                    // Figma: 상태바부터 흰색 → 하늘색(Base/Blue/Blue 50) 한 장 그라데이션.
                    // 실시간 주문이 없으면(매장 이름 줄만 있으면) 밋밋해 보이지 않도록 이 배경도 끈다.
                    // 패널이 펼쳐져 있으면 패널까지 이어지는 "한 장" 그라데이션의 앞부분만 그린다
                    // (headerGradient 참고 — 패널이 따로 흰색에서 다시 시작하면 이음새가 보인다).
                    if !viewModel.liveOrders.isEmpty {
                        headerGradient
                    }
                }

                if viewModel.hasNoMenu {
                    emptyMenuResultView
                } else {
                    menuListContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // 진행 중인 주문이 2건 이상일 때, 헤더의 "외 N건"을 눌러 펼치는 목록 패널 + 뒤 딤.
            // topBar 바로 아래(topBarHeight만큼 내려서)에서 시작해야 해서, 이 ZStack의 다른
            // 레이어들과 별개로 맨 위 정렬 + 패딩으로 위치를 맞춘다.
            livePanelOverlay

            Group {
                if !cart.isEmpty {
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
        .toolbar(.hidden, for: .navigationBar)
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { screenHeight = $0 }
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
                    // 배지는 다크모드에서도 항상 흰색이어야 해서, 모드에 따라 어두워지는
                    // backgroundDefault 대신 다크 배리언트가 없는 고정 흰색 fillInverse를 쓴다.
                    .background(Colors.fillInverse)
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

    private func liveOrderTapped(_ order: LiveOrder) {
        router.path.append(HomeRoute.orderDetail(pickupNumber: order.pickupNumber, storeName: order.storeName))
    }

    // 헤더의 "외 N건"을 눌렀을 때(진행 중인 주문이 2건 이상일 때만 쓰인다). 패널을 열 때와 닫을 때
    // 커브·시간이 서로 달라서(Figma: 열기 0.36s, 닫기 0.22s, 둘 다 ease-out) 선언적
    // .animation(value:) 한 줄로는 양방향을 다르게 줄 수 없어 여기서 방향별로 직접 감싼다.
    private func toggleLivePanel() {
        if isLivePanelExpanded {
            withAnimation(anim(Self.livePanelCloseAnimation)) { isLivePanelExpanded = false }
        } else {
            withAnimation(anim(Self.livePanelOpenAnimation)) { isLivePanelExpanded = true }
        }
    }

    private func closeLivePanelIfNeeded() {
        guard isLivePanelExpanded else { return }
        withAnimation(anim(Self.livePanelCloseAnimation)) { isLivePanelExpanded = false }
    }

    // 주문이 1건이면 142, 2건 이상이면(가로 캐러셀 + 페이지 점) 158.
    private var liveSectionExpandedHeight: CGFloat {
        viewModel.liveOrders.count > 1 ? Self.liveSectionHeightMulti : Self.liveSectionHeightSingle
    }

    // 펼쳐진 상태(맨 위)에서는 메뉴 홈 헤더 바로 아래 자리 잡은 실시간 현황이다. 스크롤해서
    // 접히면 높이·투명도가 0으로 줄며 사라지고, 그 대신 헤더의 매장 이름 자리에
    // LiveOrderHeaderView가 올라온다(showsLiveHeader). 주문이 1건이면 바 하나, 2건 이상이면
    // 화면 폭 한 장씩 넘기는 캐러셀 + 페이지 점(Figma "2건이면 화면 폭 한 장씩 넘기기 + 점").
    @ViewBuilder
    private var liveSection: some View {
        if !viewModel.liveOrders.isEmpty {
            VStack(spacing: Spacing.spacing8) {
                if viewModel.liveOrders.count == 1 {
                    LiveOrderBarView(order: viewModel.liveOrders[0], action: { liveOrderTapped(viewModel.liveOrders[0]) })
                } else {
                    liveOrderCarousel
                    liveOrderCarouselDots
                }
            }
            .frame(height: liveSectionExpandedHeight * (1 - liveSectionCollapseProgress), alignment: .top)
            // 높이가 줄어드는 동안 글자·일러스트가 짓눌려 보이지 않도록 투명도를 더 빠르게 뺀다.
            .opacity(1 - min(liveSectionCollapseProgress * 1.6, 1))
            .clipped()
            .allowsHitTesting(liveSectionCollapseProgress < 1)
        }
    }

    private var liveOrderCarousel: some View {
        TabView(selection: $liveCarouselIndex) {
            ForEach(Array(viewModel.liveOrders.enumerated()), id: \.element) { index, order in
                LiveOrderBarView(order: order, action: { liveOrderTapped(order) })
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: Self.liveOrderBarHeight)
        // 주문 목록이 바뀌어 지금 보던 페이지가 없어지면(예: 맨 앞 주문이 픽업 완료로 사라짐) 첫
        // 페이지로 되돌린다.
        .onChange(of: viewModel.liveOrders) { _, newOrders in
            if liveCarouselIndex >= newOrders.count {
                liveCarouselIndex = max(newOrders.count - 1, 0)
            }
        }
    }

    // Figma 점 인디케이터(1226:48988 "Dots") 실측: 지름 8의 원 두 개, 중심 간 14(= 모서리 간 6),
    // 둘 다 같은 크기의 원이고 활성 점이 캡슐처럼 넓어지지 않는다. 비활성 점 색은 Figma 원본이
    // neutral-weak(5% 불투명도)인데 실제 화면에서 거의 안 보여서, "옅지만 보이는" 용도인
    // iconQuaternary(18%)로 한 단계 진하게 했다(사용자 피드백).
    private var liveOrderCarouselDots: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.liveOrders.indices, id: \.self) { index in
                Circle()
                    .fill(index == liveCarouselIndex ? Colors.fillBrand : Colors.iconQuaternary)
                    .frame(width: 8, height: 8)
            }
        }
        .animation(anim(.easeOut(duration: 0.15)), value: liveCarouselIndex)
        // Figma 원본값 14 — 간격 스케일(8/16)에는 안 맞는 한 번뿐인 값이라 리터럴로 둔다.
        .padding(.bottom, 14)
    }

    private var showsLiveHeader: Bool {
        !viewModel.liveOrders.isEmpty && liveSectionCollapseProgress >= 1
    }

    // 스크롤 콘텐츠 맨 위 마커의 Y좌표(0 = 맨 위, 음수 = 스크롤한 만큼)로 Live Section이
    // 얼마나 접혔는지를 계산한다.
    // 별도 마커 대신, 이미 양방향으로(올리고 내리고 전부) 검증된 SectionTopOffsetKey 값을 그대로
    // 쓴다 — 첫 섹션은 스크롤 콘텐츠 맨 위에 간격 없이 바로 붙어 있어서, 그 상단 좌표가 곧
    // "맨 위에서 얼마나 스크롤했는지"와 같다. 전용 마커 뷰를 따로 뒀던 이전 버전은 스크롤을
    // 올렸다 내렸다 해도 갱신되지 않는 문제가 있었다.
    private func updateLiveSectionProgress(_ offsets: [HomeMenuViewModel.Section: CGFloat]) {
        guard !viewModel.liveOrders.isEmpty,
              let firstSection = viewModel.sections.first,
              let topOffset = offsets[firstSection] else {
            liveSectionCollapseProgress = 0
            return
        }
        liveSectionCollapseProgress = min(max(-topOffset / liveSectionExpandedHeight, 0), 1)
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
            menuScrollArea
        }
        // Figma: 실시간 주문이 떠 있을 때만 "최근 주문" 구역 전체(탭 포함)가 위 하늘색 그라데이션
        // 위에 얹힌 흰 시트처럼 위쪽 두 모서리가 둥글다(Section · 최근 주문, radius-2xl = 24).
        // 주문이 없을 때는 각지게 그대로 둔다.
        //
        // clipShape(+compositingGroup)로 이 블록 전체를 둥글게 깎는 방식은 두 가지 문제가 있었다:
        // 1) tabsBar 안 가로 스크롤(UIKit 레이어)이 clipShape를 무시해서 compositingGroup이
        //    필요했는데, 2) compositingGroup을 걸면 tabsBar가 자기 안의 가로 스크롤 위치를 재는
        //    GeometryReader 값(TabsContentFrameKey 등)을 더는 제대로 못 읽어서, 끝에 닿았는지
        //    보여주는 좌우 Fog가 항상 안 보이게 돼버렸다.
        // 그 다음 시도(흰 원 + 하늘색 배경 patch)는 tabsBar 위에 "불투명한 흰 원"을 overlay로
        // 덮어서, 탭 글자가 그 24×24 모서리 칸 안에 걸리면 그 위를 그대로 덮어 가려버렸다
        // (overlay는 clipShape와 달리 "지우는" 게 아니라 "그 위에 덧칠"하는 것이라 당연한 결과였다).
        // 지금은 실제로 깎여 나가야 하는 작은 쐐기 모양(사각형 - 원)만 Path로 직접 그려서 그
        // 부분에만 하늘색을 칠한다 — 쐐기는 진짜 모서리 꼭짓점 쪽으로 좁아지는 작은 조각이라
        // 안쪽의 탭 글자(패딩 16pt 뒤에서 시작)를 덮을 일이 없다. tabsBar 자체는 여전히 전혀
        // 건드리지 않는다.
        .overlay(alignment: .topLeading) { roundedCornerPatch(mirrored: false) }
        .overlay(alignment: .topTrailing) { roundedCornerPatch(mirrored: true) }
    }

    // 사각형(모서리 patch 전체)에서 안쪽 둥근 원을 뺀 나머지 — 즉 실제로 "깎여 나가는" 쐐기
    // 모양만 그린다. mirrored == false면 top-leading(왼쪽 위), true면 top-trailing(오른쪽 위).
    private struct RoundedCornerWedge: Shape {
        let mirrored: Bool

        func path(in rect: CGRect) -> Path {
            let square = Path(rect)
            let circleOriginX = mirrored ? rect.minX - rect.width : rect.maxX - rect.width
            let circle = Path(
                ellipseIn: CGRect(
                    x: circleOriginX,
                    y: rect.maxY - rect.height,
                    width: rect.width * 2,
                    height: rect.height * 2
                )
            )
            return square.subtracting(circle)
        }
    }

    @ViewBuilder
    private func roundedCornerPatch(mirrored: Bool) -> some View {
        if !viewModel.liveOrders.isEmpty {
            RoundedCornerWedge(mirrored: mirrored)
                .fill(Colors.baseBlue50)
                .frame(width: Radius.xxl, height: Radius.xxl)
                .allowsHitTesting(false)
        }
    }

    private var menuScrollArea: some View {
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
                            updateLiveSectionProgress(offsets)
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
                        .onChange(of: viewModel.isProgrammaticScrollInProgress) {
                            guard !viewModel.isProgrammaticScrollInProgress else { return }
                            programmaticScrollSettleGuardUntil = Date().addingTimeInterval(Self.scrollSpySettleWindow)
                        }
                    }

                    LinearGradient(
                        colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: Spacing.spacing40)
                    .allowsHitTesting(false)
                }
                // 그라데이션 하나에만 걸면 조상 GeometryReader/ZStack이 보고하는 크기가 세이프에리어
                // 안쪽으로 다시 당겨질 때(OS 버전에 따라 생김) 그라데이션도 같이 위로 밀린다.
                // 이 ZStack 전체를 기준으로 걸어야 하단 끝까지 항상 빈틈없이 붙는다.
                .ignoresSafeArea(edges: .bottom)
                .onAppear { listViewportHeight = listGeometry.size.height }
                .onChange(of: listGeometry.size.height) { _, newValue in listViewportHeight = newValue }
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
            storeNameAndLiveHeaderSwap

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
        // 실시간 주문이 있으면(liveOrders가 비어있지 않으면) 상태바부터 이어지는 하늘색
        // 그라데이션이 topBar 뒤까지 깔려야 해서, 여기서는 배경을 따로 칠하지 않는다(그라데이션은
        // content의 ZStack(alignment: .top)에서 한 장으로 그린다).
        // PreferenceKey + onPreferenceChange 조합은 이 자리에서 가장 바깥 onPreferenceChange까지
        // 값이 전달되지 않는 문제가 실측으로 확인됐다(GeometryReader 자체는 정상 측정).
        // onGeometryChange(iOS 17+)로 바꿔 이 뷰 자신에서 바로 topBarHeight를 갱신한다.
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { topBarHeight = $0 }
    }

    // 매장 이름 줄 ↔ Live Order Header. Figma 주석: "현황 구역 아랫선이 헤더 아랫선(106)에
    // 닿는 순간 매장 이름 올라가고 Live Order Header 올라온다. 0.45s, cubic(0.2, 0.9, 0.25, 1).
    // 다시 올리면 반대로." 둘을 같은 자리에 겹쳐 두고 오프셋+투명도로 바꿔치기해서, 전환
    // 중에도 옆의 검색·내 정보 아이콘 위치가 흔들리지 않게 한다.
    private var storeNameAndLiveHeaderSwap: some View {
        ZStack(alignment: .leading) {
            storeNameButton
                .offset(y: slideOffset(isLiveHeader: false))
                .opacity(showsLiveHeader ? 0 : 1)

            if let liveOrder = viewModel.liveOrders.first {
                // 주문이 1건이면 그대로 상세로, 2건 이상이면("외 N건") 직접 상세로 가는 대신
                // 바로 아래 패널을 펼친다(Figma: "Orders=2건이면 ... 누르면 헤더 아래 패널").
                LiveOrderHeaderView(
                    order: liveOrder,
                    additionalCount: max(viewModel.liveOrders.count - 1, 0),
                    action: {
                        if viewModel.liveOrders.count > 1 {
                            toggleLivePanel()
                        } else {
                            liveOrderTapped(liveOrder)
                        }
                    }
                )
                .offset(y: slideOffset(isLiveHeader: true))
                .opacity(showsLiveHeader ? 1 : 0)
            }
        }
        .animation(headerSwapAnimation, value: showsLiveHeader)
    }

    private var storeNameButton: some View {
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
    }

    // 동작 줄이기가 켜져 있으면 슬라이드 대신 0.2초 페이드만 쓴다(Figma 주석: "움직임 줄이기 = 페이드 0.2s").
    private var headerSwapAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : Self.liveHeaderSwapAnimation
    }

    private func slideOffset(isLiveHeader: Bool) -> CGFloat {
        guard !reduceMotion else { return 0 }
        let isVisible = isLiveHeader == showsLiveHeader
        return isVisible ? 0 : (isLiveHeader ? Self.liveHeaderSwapSlideDistance : -Self.liveHeaderSwapSlideDistance)
    }

    // 헤더의 "외 N건"을 눌러 펼치는 목록 패널 + 뒤 딤(Figma development 주석: "헤더 아래 패널
    // 높이 0 → 줄 합계, 0.36s / 닫기 0.22s ease-out. 뒤 Dim 20%. 3건 이상이면 화면 60%까지,
    // 넘치면 패널 안에서 스크롤. 헤더 + 패널 = 한 장 그라데이션, 줄 사이 구분선 없음, 아래
    // 모서리 20."). 딤·패널 모두 항상 트리에 두고 투명도·높이만 바꿔서, 조건부 삽입/제거가
    // 아니라 진짜 애니메이션으로 열리고 닫히게 한다(liveSection 접힘과 같은 방식).
    private var livePanelOverlay: some View {
        ZStack(alignment: .top) {
            // 헤더(topBar)는 패널을 연 당사자이자 계속 탭 가능한 트리거라 딤 밑에 깔리면 안
            // 된다 — 화면 전체를 덮은 뒤 topBarHeight만큼 내려서, 헤더는 밝게 남기고 그 아래
            // 콘텐츠만 어둡게 한다(실측 확인: 전체를 덮으면 헤더 줄만 어두워지는 이음새가 보였다).
            Colors.backgroundDim
                .opacity(isLivePanelExpanded ? 1 : 0)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
                .allowsHitTesting(isLivePanelExpanded)
                .onTapGesture { closeLivePanelIfNeeded() }
                .padding(.top, topBarHeight)

            livePanelContent
                .padding(.top, topBarHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // 헤더 바로 아래, 패널이 나타나기 전 실제로 보이는 헤더 블록(topBar + 아직 안 접힌 liveSection)의
    // 실측 높이. 패널은 항상 showsLiveHeader(완전히 접힘) 상태에서만 열리므로 보통 topBar
    // 높이와 같지만, 강제로 펼쳐본 상태 등 liveSection이 덜 접혔을 때도 이어지는 그라데이션
    // 계산에 정확한 값을 쓰기 위해 접힘 진행도를 그대로 반영한다.
    private var headerBlockHeight: CGFloat {
        topBarHeight + liveSectionExpandedHeight * (1 - liveSectionCollapseProgress)
    }

    // Figma 주석 "헤더 + 패널 = 한 장 그라데이션"을 실제로 구현한다. 헤더와 패널이 각자 독립적으로
    // 흰색→하늘색을 처음부터 다시 그리면 그 경계에서 색이 끊기는 게 실측으로 보였다(흰색이 다시
    // 튀어나옴). 두 그라데이션이 같은 전체 길이(헤더+패널)의 앞/뒷부분을 나눠 그리도록 stop
    // 위치를 0~1 밖으로 넘겨, 경계에서 색이 이어지게 한다.
    // Gradient.Stop의 location은 Apple 문서상 [0, 1] 범위를 벗어나면 동작이 정의되지 않는다
    // (실측 확인: 1을 넘기면 그냥 무시되고 기본 2단 그라데이션으로 되돌아간다). 대신 start/end
    // endPoint의 UnitPoint는 뷰 범위 밖 값도 그대로 지원하므로, 그 쪽으로 "전체 길이 중 이
    // 뷰가 차지하는 구간"을 표현한다.
    private var headerGradient: LinearGradient {
        let header = headerBlockHeight
        guard isLivePanelExpanded, header > 0 else {
            return LinearGradient(colors: [Colors.backgroundDefault, Colors.baseBlue50], startPoint: .top, endPoint: .bottom)
        }
        let panel = livePanelHeight
        return LinearGradient(
            colors: [Colors.backgroundDefault, Colors.baseBlue50],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: (header + panel) / header)
        )
    }

    private var panelGradient: LinearGradient {
        let panel = livePanelHeight
        let header = headerBlockHeight
        guard panel > 0 else {
            return LinearGradient(colors: [Colors.backgroundDefault, Colors.baseBlue50], startPoint: .top, endPoint: .bottom)
        }
        return LinearGradient(
            colors: [Colors.backgroundDefault, Colors.baseBlue50],
            startPoint: UnitPoint(x: 0.5, y: -header / panel),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }

    // "화면 60%까지, 넘치면 패널 안에서 스크롤" — screenHeight는 UIScreen.main.bounds(세이프에리어와
    // 무관한 전역값)가 아니라 topBarHeight와 같은 로컬 GeometryReader 좌표계로 잰 값이라, 세이프에리어
    // 처리 방식이 OS 버전마다 달라져도 항상 같은 기준으로 계산된다. 맨 아래 여백(가장 하단 주문 카드의
    // 글자 ~ 패널 아래쪽 모서리) 20 — 패널 자체 높이 계산에도 똑같이 더해야 잘리지 않는다.
    private var livePanelHeight: CGFloat {
        let naturalHeight = CGFloat(viewModel.liveOrders.count) * Self.liveOrderBarHeight + Spacing.spacing20
        return min(naturalHeight, screenHeight * Self.livePanelMaxHeightRatio)
    }

    private var livePanelContent: some View {
        let naturalHeight = CGFloat(viewModel.liveOrders.count) * Self.liveOrderBarHeight + Spacing.spacing20
        let cappedHeight = livePanelHeight

        return ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.liveOrders, id: \.self) { order in
                    LiveOrderBarView(order: order, action: {
                        closeLivePanelIfNeeded()
                        liveOrderTapped(order)
                    })
                }
            }
            .padding(.bottom, Spacing.spacing20)
        }
        .scrollDisabled(naturalHeight <= cappedHeight)
        .background(panelGradient)
        .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: Radius.xl, bottomTrailingRadius: Radius.xl, topTrailingRadius: 0)
        )
        .frame(height: isLivePanelExpanded ? cappedHeight : 0, alignment: .top)
        .opacity(isLivePanelExpanded ? 1 : 0)
        .clipped()
        .allowsHitTesting(isLivePanelExpanded)
    }

    private var tabsBar: some View {
        // .background(GeometryReader{...})를 가로 ScrollView에 붙이는 방식은(TabsViewportWidthKey가
        // 쓰던 이전 방식) 이 뷰포트 크기를 0으로 보고해서 좌우 Fog가 항상 안 보였다
        // (menuScrollArea 쪽에 이미 있는 것과 같은 문제 — 주석 참고). GeometryReader를
        // ScrollView의 직계 부모로 직접 감싸면 제안받은 크기를 그대로, 안정적으로 읽는다.
        GeometryReader { viewportGeometry in
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
                        // 이 HStack 전체(가로 스크롤 콘텐츠)의 크기를 재는 GeometryReader는
                        // .background로 붙이면 이 가로 ScrollView 안에서는 계속 (0,0,0,0)만
                        // 보고했다(실측 확인 — named 좌표계든 .global이든 동일). 개별 탭 버튼
                        // 하나하나를 재는 TabFrameKey(.background 그대로, 같은 ScrollView 안)는
                        // 멀쩡히 되는 걸 보면 "콘텐츠 전체 크기"를 .background로 재는 경우에만
                        // 생기는 문제로 보인다. .overlay로 바꾸니 정상적으로 측정된다.
                        .overlay(
                            GeometryReader { geometry in
                                // 뷰포트의 global 프레임과 직접 뺄셈해 "뷰포트 기준 상대 위치"를 구한다.
                                Color.clear.preference(
                                    key: TabsContentFrameKey.self,
                                    value: geometry.frame(in: .global)
                                )
                            }
                        )
                    }
                    .onPreferenceChange(TabsContentFrameKey.self) { tabsContentGlobalFrame = $0 }
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
            .onAppear { tabsViewportGlobalFrame = viewportGeometry.frame(in: .global) }
            .onChange(of: viewportGeometry.frame(in: .global)) { _, newValue in tabsViewportGlobalFrame = newValue }
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
    // (둘 다 .global 좌표계라서, 콘텐츠 시작이 뷰포트 시작보다 왼쪽에 있으면 = 오른쪽으로 스크롤된 상태)
    private var isTabsLeadingFadeVisible: Bool {
        tabsContentGlobalFrame.minX < tabsViewportGlobalFrame.minX - 1
    }

    // 탭 줄을 오른쪽으로 더 스크롤할 내용이 남아 있을 때만 오른쪽 페이드를 보여준다.
    private var isTabsTrailingFadeVisible: Bool {
        tabsContentGlobalFrame.maxX > tabsViewportGlobalFrame.maxX + 1
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
                menuCard(item)
            }
        }
    }

    // 섹션 바로 위 두꺼운 디바이더의 "상단"이 화면 맨 위에 닿거나 넘어가는 순간 바로 그
    // 섹션으로 하이라이트를 옮긴다. sectionTopOffsets는 디바이더가 아니라 그 다음 섹션
    // 자체의 상단(= 디바이더 하단)을 재므로, 디바이더 높이만큼 당겨서 디바이더 상단 기준으로
    // 바꾼다.
    private func currentSectionFromScrollPosition() -> HomeMenuViewModel.Section? {
        sectionTopOffsets
            .filter { _, minY in minY - Spacing.spacing12 <= 0 }
            .max { $0.value < $1.value }?
            .key
            ?? viewModel.sections.first
    }

    // 탭 클릭으로 시작한 프로그램 스크롤이 (타임아웃이나 드래그 시작으로) 보호가 풀린 직후에도
    // 관성으로 몇 프레임 더 움직이는 경우가 있다. 그 몇 프레임 동안 onPreferenceChange가 연달아
    // 여러 섹션을 "현재"로 보고하면, 보호가 풀리자마자 그 중간 섹션들로 탭이 순간적으로
    // 전부 튀어 보인다(실측 확인 — 드래그 직후 한 탭 틱 사이에 5개 섹션을 연쇄적으로 거침).
    // 디바운스는 보호가 풀린 직후의 아주 짧은 구간(scrollSpySettleWindow)에만 적용한다.
    // 평소 손가락 스크롤에는 전혀 적용되지 않아, 디바이더를 지나는 즉시 하이라이트가 바뀐다.
    private static let scrollSpySettleDelay: Duration = .milliseconds(80)
    private static let scrollSpySettleWindow: TimeInterval = 0.15

    private func updateCurrentSectionFromScroll() {
        guard let current = currentSectionFromScrollPosition() else { return }

        guard let guardUntil = programmaticScrollSettleGuardUntil, Date() < guardUntil else {
            viewModel.updateSelectedSectionFromScroll(current)
            return
        }

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
        router.path.append(HomeRoute.search(storeId: viewModel.currentStoreId, items: searchableMenuItems))
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
        router.path.append(HomeRoute.menuOptions(storeId: viewModel.currentStoreId, item: item))
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

#Preview("Live Order") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.liveOrders = [
                LiveOrder(pickupNumber: 27, storeName: viewModel.storeName, stage: .making, queueCount: 2, pickupDeadlineText: "")
            ]
        }
}

#Preview("Live Order · 2건") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.liveOrders = [
                LiveOrder(pickupNumber: 27, storeName: viewModel.storeName, stage: .making, queueCount: 2, pickupDeadlineText: ""),
                LiveOrder(pickupNumber: 28, storeName: viewModel.storeName, stage: .confirming, queueCount: 3, pickupDeadlineText: "")
            ]
        }
}

#Preview("Live Order · 3건") {
    let viewModel = HomeMenuViewModel()
    return HomeMenuView(viewModel: viewModel)
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            viewModel.liveOrders = [
                LiveOrder(pickupNumber: 27, storeName: viewModel.storeName, stage: .making, queueCount: 2, pickupDeadlineText: ""),
                LiveOrder(pickupNumber: 28, storeName: viewModel.storeName, stage: .confirming, queueCount: 3, pickupDeadlineText: ""),
                LiveOrder(pickupNumber: 29, storeName: viewModel.storeName, stage: .readyForPickup, queueCount: 0, pickupDeadlineText: "13:30까지 받아주세요")
            ]
        }
}
