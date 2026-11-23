import Foundation

enum OrderStatus {
    case confirming
    case making
    case waitingPickup
    case cancelled
    case pickedUp
    // 사용자가 직접 주문을 취소한 상태. 매장이 거절한 cancelled와는 구분한다.
    case userCancelled
    // 픽업까지 끝난 뒤(또는 취소 후) 환불이 완료된 상태.
    case refunded
    // 픽업 대기 시간 안에 찾아가지 않은 상태.
    case unclaimed
}

struct OrderItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let optionsSummary: String
}

struct Order {
    let pickupNumber: Int
    let storeName: String
    var status: OrderStatus
    let items: [OrderItem]
    let subtotalPrice: Int
    let paymentMethod: PaymentMethod
    let paidAt: Date
    var confirmedAt: Date
    var madeAt: Date?
    var waitingAt: Date?
    var pickedUpAt: Date?
    var userCancelledAt: Date?
    var refundedAt: Date?
    var unclaimedAt: Date?
}

protocol OrderRepository {
    func fetchOrder(pickupNumber: Int, storeName: String) async throws -> Order
}
