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
    // 주문이 사라지면(픽업 완료 등) nil을 내보낸다.
    func observeLiveOrder(storeName: String) -> AsyncStream<LiveOrder?>
}
