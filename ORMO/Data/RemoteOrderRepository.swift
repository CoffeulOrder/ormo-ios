import Foundation

// 결제수단(토스페이 등)은 서버가 구분하지 않는 화면 전용 값이라, 주문 생성 시점에 기억해뒀다가
// 조회할 때 같이 붙여준다. 앱을 새로 시작하면 사라지지만, 그때는 이미 지난 주문의 결제수단이라
// 다시 바뀔 일이 없어 기본값(card)으로 보여줘도 괜찮다.
private final class OrderPaymentMethodMemory {
    static let shared = OrderPaymentMethodMemory()
    private var methods: [Int: PaymentMethod] = [:]
    private init() {}

    func set(_ method: PaymentMethod, for orderId: Int) { methods[orderId] = method }
    func get(for orderId: Int) -> PaymentMethod? { methods[orderId] }
}

struct RemoteOrderRepository: OrderRepository {
    private struct OrderItemBody: Encodable {
        let menuId: Int
        let quantity: Int
        let optionItemIds: [Int]
    }

    private struct CreateOrderBody: Encodable {
        let storeId: Int
        let items: [OrderItemBody]
        let withdrawalLimitAgreed: Bool
    }

    private struct PortOneCheckoutData: Decodable {
        let storeId: String
        let channelKey: String
        let paymentId: String
        let currency: String
    }

    private struct PaymentData: Decodable {
        let orderName: String
        let amount: Int
        let portOne: PortOneCheckoutData
    }

    // POST /orders와 POST /orders/{orderId}/payment-attempts(재시도) 둘 다 이 모양으로 응답한다.
    private struct CreateOrderResponseData: Decodable {
        let orderId: Int
        let payment: PaymentData
    }

    private struct OrderItemData: Decodable {
        let menuName: String
        let options: [String]
        let quantity: Int
    }

    private struct StoreRefData: Decodable {
        let storeId: Int
        let name: String
    }

    private struct TimelineData: Decodable {
        let placedAt: String
        let acceptedAt: String?
        let makingAt: String?
        let readyAt: String?
        let completedAt: String?
        let canceledAt: String?
        let rejectedAt: String?
    }

    private struct OrderDetailData: Decodable {
        let orderId: Int
        let status: String
        let store: StoreRefData
        let pickupNo: Int?
        let items: [OrderItemData]
        let subtotalAmount: Int
        let timeline: TimelineData
        let refundStatus: String?
    }

    private struct CancelBody: Encodable {
        let reason: String?
    }

    private struct OrderListData: Decodable {
        let content: [EmptyAPIData]
    }

    func createOrder(
        storeId: String,
        storeName: String,
        items: [CartLineItem],
        paymentMethod: PaymentMethod,
        withdrawalLimitAgreed: Bool
    ) async throws -> CreatedOrder {
        guard let storeIdInt = Int(storeId) else { throw APIError.invalidURL }

        let body = CreateOrderBody(
            storeId: storeIdInt,
            items: items.map {
                OrderItemBody(
                    menuId: Int($0.menuItemId) ?? 0,
                    quantity: $0.quantity,
                    optionItemIds: $0.optionItemIds.compactMap(Int.init)
                )
            },
            withdrawalLimitAgreed: withdrawalLimitAgreed
        )

        do {
            return try await performCreate(body: body, paymentMethod: paymentMethod)
        } catch let error as APIError {
            // 이전 시도와 다른 본문으로 같은 Idempotency-Key를 재전송한 경우. 키를 새로 받아 한 번만 재시도한다.
            guard error.serverCode == "OD010" else { throw error }
            IdempotencyKeyProvider.shared.discard()
            return try await performCreate(body: body, paymentMethod: paymentMethod)
        }
    }

    private func performCreate(body: CreateOrderBody, paymentMethod: PaymentMethod) async throws -> CreatedOrder {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/orders",
            body: body,
            idempotencyKey: IdempotencyKeyProvider.shared.currentOrNewKey()
        )
        let data: CreateOrderResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: CreateOrderResponseData.self)
        IdempotencyKeyProvider.shared.discard()
        OrderPaymentMethodMemory.shared.set(paymentMethod, for: data.orderId)
        return Self.mapToCreatedOrder(data)
    }

    func retryPaymentAttempt(orderId: Int) async throws -> CreatedOrder {
        let endpoint = Endpoint(method: .post, path: "/api/v1/orders/\(orderId)/payment-attempts")
        let data: CreateOrderResponseData = try await APIClient.shared.send(endpoint, decodingDataAs: CreateOrderResponseData.self)
        return Self.mapToCreatedOrder(data)
    }

    private static func mapToCreatedOrder(_ data: CreateOrderResponseData) -> CreatedOrder {
        CreatedOrder(
            orderId: data.orderId,
            portOneStoreId: data.payment.portOne.storeId,
            channelKey: data.payment.portOne.channelKey,
            paymentId: data.payment.portOne.paymentId,
            currency: data.payment.portOne.currency,
            orderName: data.payment.orderName,
            amount: data.payment.amount
        )
    }

    func fetchOrder(orderId: Int) async throws -> Order {
        let endpoint = Endpoint(method: .get, path: "/api/v1/orders/\(orderId)")
        let data: OrderDetailData = try await APIClient.shared.send(endpoint, decodingDataAs: OrderDetailData.self)
        return Self.mapToOrder(data)
    }

    func cancelOrder(orderId: Int, reason: String?) async throws {
        let endpoint = Endpoint(method: .post, path: "/api/v1/orders/\(orderId)/cancel", body: CancelBody(reason: reason))
        try await APIClient.shared.send(endpoint)
    }

    func fetchActiveOrderCount() async throws -> Int {
        let endpoint = Endpoint(
            method: .get,
            path: "/api/v1/orders",
            queryItems: [URLQueryItem(name: "filter", value: "ACTIVE"), URLQueryItem(name: "size", value: "50")]
        )
        let data: OrderListData = try await APIClient.shared.send(endpoint, decodingDataAs: OrderListData.self)
        return data.content.count
    }

    private static func mapToOrder(_ data: OrderDetailData) -> Order {
        let isRefunded = data.refundStatus == "SUCCEEDED"
        let status: OrderStatus
        switch data.status {
        case "REQUESTED", "ACCEPTED": status = .confirming
        case "MAKING": status = .making
        case "READY": status = .waitingPickup
        case "COMPLETED": status = .pickedUp
        case "CANCELED": status = isRefunded ? .refunded : .userCancelled
        case "REJECTED": status = isRefunded ? .refunded : .cancelled
        default: status = .confirming
        }

        return Order(
            orderId: data.orderId,
            storeId: String(data.store.storeId),
            pickupNumber: data.pickupNo ?? 0,
            storeName: data.store.name,
            status: status,
            items: data.items.map { OrderItem(name: $0.menuName, quantity: $0.quantity, optionsSummary: $0.options.joined(separator: " | ")) },
            subtotalPrice: data.subtotalAmount,
            paymentMethod: OrderPaymentMethodMemory.shared.get(for: data.orderId) ?? .card,
            paidAt: APIDateParsing.date(data.timeline.placedAt) ?? Date(),
            confirmedAt: APIDateParsing.date(data.timeline.acceptedAt) ?? APIDateParsing.date(data.timeline.placedAt) ?? Date(),
            madeAt: APIDateParsing.date(data.timeline.makingAt),
            waitingAt: APIDateParsing.date(data.timeline.readyAt),
            pickedUpAt: APIDateParsing.date(data.timeline.completedAt),
            userCancelledAt: APIDateParsing.date(data.timeline.canceledAt),
            refundedAt: isRefunded ? (APIDateParsing.date(data.timeline.canceledAt) ?? APIDateParsing.date(data.timeline.rejectedAt)) : nil,
            unclaimedAt: nil
        )
    }
}
