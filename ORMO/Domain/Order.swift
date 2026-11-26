import Foundation

enum OrderStatus: Hashable, Codable {
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

struct OrderItem: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let quantity: Int
    let optionsSummary: String

    init(id: UUID = UUID(), name: String, quantity: Int, optionsSummary: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.optionsSummary = optionsSummary
    }
}

struct Order: Hashable, Codable {
    let orderId: Int
    let storeId: String
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

extension Order {
    // OrderDetailViewModel이 실제 주문을 받아오기 전까지 잠깐 보여줄 자리표시자, 그리고 Preview 전용.
    static func mock(orderId: Int = 0, storeId: String = "", pickupNumber: Int = 0, storeName: String) -> Order {
        let now = Date()
        return Order(
            orderId: orderId,
            storeId: storeId,
            pickupNumber: pickupNumber,
            storeName: storeName,
            status: .confirming,
            items: [
                OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가"),
                OrderItem(name: "아메리카노", quantity: 1, optionsSummary: "M | ICE | 샷추가")
            ],
            subtotalPrice: 3000,
            paymentMethod: .card,
            paidAt: now,
            confirmedAt: now
        )
    }
}

// 주문을 만들면(POST /orders) 결제 확인 전까지는 픽업번호 등이 아직 없는 PENDING_PAYMENT
// 상태라, 그 짧은 구간만 이 가벼운 값으로 들고 다닌다. 결제가 확인된 뒤에야 진짜 Order가 된다.
struct CreatedOrder: Hashable {
    let orderId: Int
    let pgOrderId: String
}

protocol OrderRepository {
    // paymentMethod: 서버는 PG사(FAKE·실결제)만 구분하고 "토스페이·카카오페이" 같은 화면용
    // 결제수단 구분은 모른다 — 주문 상세에 계속 보여주려고 생성 시점에 같이 들고 다닌다.
    func createOrder(
        storeId: String,
        storeName: String,
        items: [CartLineItem],
        paymentMethod: PaymentMethod,
        withdrawalLimitAgreed: Bool
    ) async throws -> CreatedOrder
    func fetchOrder(orderId: Int) async throws -> Order
    func cancelOrder(orderId: Int, reason: String?) async throws
    // 마이페이지 탈퇴 전 "진행 중인 주문" 확인에 쓴다.
    func fetchActiveOrderCount() async throws -> Int
}

protocol OrderHistoryRepository {
    func fetchOrderHistory() async throws -> [Order]
}
