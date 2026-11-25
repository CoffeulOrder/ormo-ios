import Foundation

@Observable
final class OrderDetailViewModel {
    private(set) var order: Order

    private let repository: OrderRepository
    private let menuRepository: MenuRepository
    private let autoProgress: Bool
    private var progressionTask: Task<Void, Never>?

    init(
        pickupNumber: Int,
        storeName: String,
        repository: OrderRepository = MockOrderRepository(),
        menuRepository: MenuRepository = MockMenuRepository()
    ) {
        self.repository = repository
        self.menuRepository = menuRepository
        self.order = .mock(pickupNumber: pickupNumber, storeName: storeName)
        self.autoProgress = true
    }

    // 프리뷰에서 각 상태(확인 중/만드는 중/픽업 대기/매장 취소/픽업 완료)를 바로 확인하기 위한 생성자.
    // 자동 진행 Task는 걸지 않는다 — 특정 상태를 고정해서 보는 게 목적이라서.
    init(
        order: Order,
        repository: OrderRepository = MockOrderRepository(),
        menuRepository: MenuRepository = MockMenuRepository()
    ) {
        self.repository = repository
        self.menuRepository = menuRepository
        self.order = order
        self.autoProgress = false
    }

    func start() {
        guard autoProgress, progressionTask == nil else { return }
        progressionTask = Task {
            guard let fetched = try? await repository.fetchOrder(pickupNumber: order.pickupNumber, storeName: order.storeName) else { return }
            order = fetched
            // 실시간 현황을 켜둔 사용자에게는 잠금 화면 Live Activity로, 꺼둔 사용자에게는
            // OrderPushNotifier의 대체 알림으로 보여준다 (둘 다 켤 일은 없다).
            await OrderLiveActivityController.start(for: order, queueCount: 3)
            await runProgression()
        }
    }

    // 매장이 주문을 처리하는 과정을 흉내 낸 Mock 진행: 4초마다 다음 단계로 자동 넘어간다.
    // 실제로는 매장 POS 상태 변경을 서버가 폴링·푸시로 알려주는 자리이며, Remote Repository가 대체한다.
    private func runProgression() async {
        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .making
        order.madeAt = Date()
        LocalStore.shared.updateOrder(order)
        await OrderLiveActivityController.update(for: order, queueCount: 2)

        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .waitingPickup
        order.waitingAt = Date()
        LocalStore.shared.updateOrder(order)
        await OrderPushNotifier.scheduleIfNeeded(for: order)
        await OrderLiveActivityController.update(for: order)

        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .pickedUp
        order.pickedUpAt = Date()
        LocalStore.shared.updateOrder(order)
        await OrderLiveActivityController.end(for: order)
    }

    // 사용자가 "주문 취소하기"를 눌렀을 때. 자동 진행 중이었다면 멈추고 취소 상태로 바꾼다.
    func cancelOrder() {
        progressionTask?.cancel()
        order.status = .userCancelled
        order.userCancelledAt = Date()
        LocalStore.shared.updateOrder(order)
        Task { await OrderLiveActivityController.end(for: order) }
    }

    deinit {
        progressionTask?.cancel()
    }

    // 주문에 담겼던 메뉴를 장바구니에 그대로 넣을 수 있는 형태로 돌려준다. 그때 고른 옵션(optionsSummary)은
    // 그대로 가져가고, 가격·현재 품절 여부만 지금 메뉴에서 이름으로 맞춰 다시 확인한다(OrderHistoryViewModel과 동일한 방식).
    // 담긴 메뉴가 전부 품절이면 nil을 돌려준다.
    func reorderLineItems() async -> [CartLineItem]? {
        guard let menu = try? await menuRepository.fetchStoreMenu(storeId: "beomseokgwan") else {
            return order.items.map { orderItem in
                CartLineItem(
                    id: UUID().uuidString,
                    menuItemId: orderItem.name,
                    menuItemName: orderItem.name,
                    quantity: orderItem.quantity,
                    unitPrice: order.subtotalPrice / max(order.items.count, 1),
                    optionsSummary: orderItem.optionsSummary
                )
            }
        }

        let availableItems = menu.recentOrders + menu.categories.flatMap(\.items)
        let lineItems = order.items.compactMap { orderItem -> CartLineItem? in
            guard let match = availableItems.first(where: { $0.name == orderItem.name }), !match.isSoldOut else { return nil }
            return CartLineItem(
                id: UUID().uuidString,
                menuItemId: match.id,
                menuItemName: match.name,
                quantity: orderItem.quantity,
                unitPrice: match.price,
                optionsSummary: orderItem.optionsSummary
            )
        }
        return lineItems.isEmpty ? nil : lineItems
    }
}
