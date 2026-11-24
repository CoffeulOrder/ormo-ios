import Foundation

// 홈 화면 하단의 "진행 중인 주문" 바. LocalStore에 실제로 진행 중(픽업 전)인 주문이 있으면 그 상태를
// 보여주고, 없으면(또는 픽업·취소로 끝나면) 사라진다. OrderDetailViewModel이 다른 화면에서 상태를
// 바꾸므로, 1초 간격으로 LocalStore를 들여다봐서 바뀐 게 있을 때만 새로 내보낸다.
struct MockLiveOrderRepository: LiveOrderRepository {
    private static let terminalStatuses: Set<OrderStatus> = [.pickedUp, .cancelled, .userCancelled, .refunded, .unclaimed]

    func observeLiveOrder(storeName: String) -> AsyncStream<LiveOrder?> {
        AsyncStream { continuation in
            let task = Task {
                var lastSignature: String?
                while !Task.isCancelled {
                    let liveOrder = Self.currentLiveOrder(storeName: storeName)
                    let signature = liveOrder.map { "\($0.pickupNumber)-\($0.stage)-\($0.queueCount)-\($0.pickupDeadlineText)" }
                    if signature != lastSignature {
                        continuation.yield(liveOrder)
                        lastSignature = signature
                    }
                    try? await Task.sleep(for: .seconds(1))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func currentLiveOrder(storeName: String) -> LiveOrder? {
        guard let order = LocalStore.shared.orders.first(where: {
            $0.storeName == storeName && !terminalStatuses.contains($0.status)
        }) else { return nil }

        let stage: OrderStage
        let queueCount: Int
        let pickupDeadlineText: String
        switch order.status {
        case .confirming:
            stage = .confirming
            queueCount = 3
            pickupDeadlineText = ""
        case .making:
            stage = .making
            queueCount = 2
            pickupDeadlineText = ""
        case .waitingPickup:
            stage = .readyForPickup
            queueCount = 0
            pickupDeadlineText = "13:30까지 받아주세요"
        case .cancelled, .pickedUp, .userCancelled, .refunded, .unclaimed:
            return nil
        }

        return LiveOrder(pickupNumber: order.pickupNumber, storeName: order.storeName, stage: stage, queueCount: queueCount, pickupDeadlineText: pickupDeadlineText)
    }
}
