import Foundation

enum OrderStatus {
    case confirming
    case making
    case waitingPickup
    case cancelled
    case pickedUp
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
}

protocol OrderRepository {
    func fetchOrder(pickupNumber: Int, storeName: String) async throws -> Order
}
