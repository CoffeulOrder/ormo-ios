import Foundation

@Observable
final class OrderDetailViewModel {
    private(set) var order: Order

    private let repository: OrderRepository
    private let menuRepository: MenuRepository
    private let autoProgress: Bool
    private var observationTask: Task<Void, Never>?

    init(
        orderId: Int,
        repository: OrderRepository = AppContainer.shared.orderRepository,
        menuRepository: MenuRepository = AppContainer.shared.menuRepository
    ) {
        self.repository = repository
        self.menuRepository = menuRepository
        self.order = .mock(orderId: orderId, storeName: "")
        self.autoProgress = true
    }

    // 프리뷰에서 각 상태(확인 중/만드는 중/픽업 대기/매장 취소/픽업 완료)를 바로 확인하기 위한 생성자.
    // 자동 진행 Task는 걸지 않는다 — 특정 상태를 고정해서 보는 게 목적이라서.
    init(
        order: Order,
        repository: OrderRepository = AppContainer.shared.orderRepository,
        menuRepository: MenuRepository = AppContainer.shared.menuRepository
    ) {
        self.repository = repository
        self.menuRepository = menuRepository
        self.order = order
        self.autoProgress = false
    }

    // Mock에서는 MockOrderRepository.fetchOrder 안에서 MockOrderProgressionScheduler가 알아서
    // 진행을 걸어준다(화면과 무관하게). 실서버는 그런 흉내가 필요 없으니 여기서는 저장소 구현이
    // 뭐든 그냥 fetch → 반영만 반복한다.
    private static var pollInterval: Duration { AppConfig.useMock ? .seconds(1) : .seconds(3) }

    func start() {
        guard autoProgress, observationTask == nil else { return }
        observationTask = Task {
            guard let fetched = try? await repository.fetchOrder(orderId: order.orderId) else { return }
            order = fetched
            // 실시간 현황을 켜둔 사용자에게는 잠금 화면 Live Activity로, 꺼둔 사용자에게는
            // OrderPushNotifier의 대체 알림으로 보여준다 (둘 다 켤 일은 없다).
            await OrderLiveActivityController.start(for: order, queueCount: 3)
            await observeProgression()
        }
    }

    // 화면 밖에서 바뀐 상태를 주기적으로 다시 읽어와 반영한다.
    // 실제로는 서버 푸시·웹소켓이 대체할 자리.
    private func observeProgression() async {
        while !Task.isCancelled {
            if let latest = try? await repository.fetchOrder(orderId: order.orderId),
               latest != order {
                order = latest
            }
            try? await Task.sleep(for: Self.pollInterval)
        }
    }

    // 사용자가 "주문 취소하기"를 눌렀을 때. 화면 관찰은 멈추고 취소 상태로 바꾼다.
    // MockOrderProgressionScheduler는 다음 단계 전환 시점에 상태가 더는 confirming/making/
    // waitingPickup이 아님을 보고 스스로 멈춘다.
    func cancelOrder() {
        observationTask?.cancel()
        order.status = .userCancelled
        order.userCancelledAt = Date()
        Task {
            try? await repository.cancelOrder(orderId: order.orderId, reason: nil)
            await OrderLiveActivityController.end(for: order)
        }
    }

    deinit {
        observationTask?.cancel()
    }

    // 주문에 담겼던 메뉴를 장바구니에 그대로 넣을 수 있는 형태로 돌려준다. 그때 고른 옵션(optionsSummary)은
    // 그대로 가져가고, 가격·현재 품절 여부만 지금 메뉴에서 이름으로 맞춰 다시 확인한다(OrderHistoryViewModel과 동일한 방식).
    // 담긴 메뉴가 전부 품절이면 nil을 돌려준다.
    func reorderLineItems() async -> [CartLineItem]? {
        guard let menu = try? await menuRepository.fetchStoreMenu(storeId: order.storeId) else {
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
