import Foundation

@Observable
final class OrderHistoryViewModel {
    private(set) var orders: [Order] = []
    private(set) var isLoaded = false
    var isSoldOutDialogVisible = false

    private let orderHistoryRepository: OrderHistoryRepository
    private let menuRepository: MenuRepository

    init(
        orderHistoryRepository: OrderHistoryRepository = AppContainer.shared.orderHistoryRepository,
        menuRepository: MenuRepository = AppContainer.shared.menuRepository
    ) {
        self.orderHistoryRepository = orderHistoryRepository
        self.menuRepository = menuRepository
    }

    func loadIfNeeded() async {
        guard !isLoaded else { return }
        orders = (try? await orderHistoryRepository.fetchOrderHistory()) ?? []
        isLoaded = true
    }

    // 주문에 담겼던 메뉴를 장바구니에 그대로 넣을 수 있는 형태로 돌려준다. 그때 고른 옵션(optionsSummary)은
    // 그대로 가져가고, 가격·현재 품절 여부만 지금 메뉴에서 이름으로 맞춰 다시 확인한다. 실제로는 서버가
    // 메뉴별 ID와 품절 여부를 바로 내려주겠지만, 지금은 Mock 메뉴에서 이름으로 맞춘다.
    // 담긴 메뉴가 전부 품절이면 nil을 돌려준다.
    func reorderLineItems(for order: Order) async -> [CartLineItem]? {
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
