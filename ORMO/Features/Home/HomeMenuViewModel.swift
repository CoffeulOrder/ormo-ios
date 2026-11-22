import Foundation

@Observable
final class HomeMenuViewModel {
    enum Section: Hashable {
        case recentOrders
        case category(String)
    }

    var storeName: String = ""
    var recentOrders: [MenuItem] = []
    var categories: [MenuCategory] = []
    var unavailableNotice: String?
    var selectedSection: Section?
    var isLoaded = false
    // 탭을 직접 눌렀을 때만 채워진다. 스크롤로 감지된 섹션 변경은 이 값을 건드리지 않아
    // 콘텐츠 스크롤과 탭 하이라이트 추적이 서로를 되돌리는 피드백 루프를 막는다.
    var scrollTarget: Section?
    var liveOrder: LiveOrder?
    var isCartSnackbarVisible = false
    var cartSnackbarMessage = ""

    var hasNoMenu: Bool { recentOrders.isEmpty && categories.isEmpty }

    private var currentStoreId = "beomseokgwan"
    private let menuRepository: MenuRepository
    private let liveOrderRepository: LiveOrderRepository
    private var liveOrderObservationTask: Task<Void, Never>?
    private var cartSnackbarTask: Task<Void, Never>?

    init(
        menuRepository: MenuRepository = MockMenuRepository(),
        liveOrderRepository: LiveOrderRepository = MockLiveOrderRepository()
    ) {
        self.menuRepository = menuRepository
        self.liveOrderRepository = liveOrderRepository
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
        guard !isLoaded else { return }
        await load(storeId: currentStoreId)
    }

    func applySelectedStore(_ store: Store) async {
        currentStoreId = store.id
        storeName = store.name
        await load(storeId: store.id)
    }

    private func load(storeId: String) async {
        guard let menu = try? await menuRepository.fetchStoreMenu(storeId: storeId) else { return }
        storeName = menu.storeName
        recentOrders = menu.recentOrders
        categories = menu.categories
        unavailableNotice = menu.unavailableNotice
        selectedSection = sections.first
        isLoaded = true
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
