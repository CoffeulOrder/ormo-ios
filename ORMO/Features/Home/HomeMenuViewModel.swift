import Foundation

@Observable
final class HomeMenuViewModel {
    enum Section: Hashable {
        case recentOrders
        case category(String)
    }

    // 6.1.1(네트워크 오류)·6.1.3(서비스 점검)·6.1.2(로그인 만료)·6.1.4(로딩) 예외 화면을
    // 이 상태 하나로 구분해서 그린다.
    enum LoadState: Equatable {
        case loading
        case loaded
        case networkError
        case serviceUnavailable
        case sessionExpired
    }

    var storeName: String = ""
    var recentOrders: [MenuItem] = []
    var categories: [MenuCategory] = []
    var unavailableNotice: String?
    var selectedSection: Section?
    var loadState: LoadState = .loading
    // 탭을 직접 눌렀을 때만 채워진다. 스크롤로 감지된 섹션 변경은 이 값을 건드리지 않아
    // 콘텐츠 스크롤과 탭 하이라이트 추적이 서로를 되돌리는 피드백 루프를 막는다.
    var scrollTarget: Section?
    var liveOrder: LiveOrder?
    var isCartSnackbarVisible = false
    var cartSnackbarMessage = ""
    // 메뉴는 정상적으로 불러왔지만 부가 정보(매장 상세) 호출만 실패했을 때, 화면 전체를
    // 막지 않고 잠깐 띄우는 토스트 (6.1.1 "연결이 불안정해요" 변형).
    var isConnectionUnstable = false
    // 장바구니 화면의 "수령 방법" 영역에 매장 이름·주소를 보여주기 위해 들고 있는다.
    var currentStore: Store?

    var hasNoMenu: Bool { recentOrders.isEmpty && categories.isEmpty }

    private var currentStoreId = "beomseokgwan"
    private var hasStartedInitialLoad = false
    private let menuRepository: MenuRepository
    private let liveOrderRepository: LiveOrderRepository
    private let cafeRepository: CafeRepository
    private var liveOrderObservationTask: Task<Void, Never>?
    private var cartSnackbarTask: Task<Void, Never>?
    private var connectionUnstableTask: Task<Void, Never>?

    init(
        menuRepository: MenuRepository = MockMenuRepository(),
        liveOrderRepository: LiveOrderRepository = MockLiveOrderRepository(),
        cafeRepository: CafeRepository = MockCafeRepository()
    ) {
        self.menuRepository = menuRepository
        self.liveOrderRepository = liveOrderRepository
        self.cafeRepository = cafeRepository
    }

    var sections: [Section] {
        var result: [Section] = []
        if !recentOrders.isEmpty {
            result.append(.recentOrders)
        }
        result.append(contentsOf: categories.map { .category($0.id) })
        return result
    }

    func sectionTitle(_ section: Section) -> String {
        switch section {
        case .recentOrders: "최근 주문"
        case .category(let id): categories.first { $0.id == id }?.name ?? ""
        }
    }

    func loadIfNeeded() async {
        guard !hasStartedInitialLoad else { return }
        hasStartedInitialLoad = true
        await load(storeId: currentStoreId)
    }

    func retryLoadTapped() {
        Task { await load(storeId: currentStoreId) }
    }

    func applySelectedStore(_ store: Store) async {
        currentStoreId = store.id
        storeName = store.name
        currentStore = store
        await load(storeId: store.id)
    }

    private func load(storeId: String) async {
        loadState = .loading
        do {
            let menu = try await menuRepository.fetchStoreMenu(storeId: storeId)
            storeName = menu.storeName
            recentOrders = menu.recentOrders
            categories = menu.categories
            unavailableNotice = menu.unavailableNotice
            selectedSection = sections.first
            loadState = .loaded

            if currentStore?.id != storeId {
                do {
                    currentStore = try await cafeRepository.fetchStores().first { $0.id == storeId }
                } catch {
                    showConnectionUnstableSnackbar()
                }
            }
        } catch MenuLoadError.network {
            loadState = .networkError
        } catch MenuLoadError.sessionExpired {
            loadState = .sessionExpired
        } catch {
            loadState = .serviceUnavailable
        }
    }

    private func showConnectionUnstableSnackbar() {
        isConnectionUnstable = true
        connectionUnstableTask?.cancel()
        connectionUnstableTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isConnectionUnstable = false
        }
    }

    func selectSection(_ section: Section) {
        selectedSection = section
        scrollTarget = section
    }

    // 스크롤 위치로 현재 보이는 섹션이 바뀌면 탭 하이라이트만 갱신한다(콘텐츠를 다시 스크롤하지 않음).
    func updateSelectedSectionFromScroll(_ section: Section) {
        guard selectedSection != section else { return }
        selectedSection = section
    }

    func observeLiveOrderIfNeeded() {
        guard liveOrderObservationTask == nil else { return }
        liveOrderObservationTask = Task { [storeName] in
            for await order in liveOrderRepository.observeLiveOrder(storeName: storeName) {
                liveOrder = order
            }
        }
    }

    func showCartAddedSnackbar(_ message: String) {
        cartSnackbarMessage = message
        isCartSnackbarVisible = true
        cartSnackbarTask?.cancel()
        cartSnackbarTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isCartSnackbarVisible = false
        }
    }
}
