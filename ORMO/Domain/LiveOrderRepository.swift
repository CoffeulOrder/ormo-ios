import Foundation

enum OrderStage: Int, Hashable {
    case confirming
    case making
    case readyForPickup
}

struct LiveOrder: Hashable {
    let pickupNumber: Int
    let storeName: String
    let stage: OrderStage
    let queueCount: Int
    let pickupDeadlineText: String
}

protocol LiveOrderRepository {
    // 진행 중인 주문이 없으면 빈 배열을 내보낸다. 최대 3건까지만 담는다.
    func observeLiveOrders(storeName: String) -> AsyncStream<[LiveOrder]>
}
