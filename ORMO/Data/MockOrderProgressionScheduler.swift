import Foundation

// 서버 없이 Mock 데이터로 개발할 때, 매장이 주문을 처리하는 과정을 고정된 시간대로 흉내 낸다:
// 주문 확인 중 5초 · 만드는 중 10초 · 픽업 대기 8초, 그 뒤 픽업 완료.
// OrderDetailViewModel이 이 진행을 직접 들고 있던 이전 버전은, 주문 상세 화면을 나가는 순간
// (deinit) 타이머가 취소돼서 홈 화면의 실시간 현황이 더는 진행되지 않는 문제가 있었다.
// 이 타입은 화면 생명주기와 무관하게 앱 전체에서 하나만 살아있어서, 어느 화면을 보고 있든
// (또는 아예 홈 화면만 보고 있든) 주문이 끝까지 진행된다.
final class MockOrderProgressionScheduler {
    static let shared = MockOrderProgressionScheduler()

    private static let confirmingDuration: TimeInterval = 5
    private static let makingDuration: TimeInterval = 10
    private static let waitingPickupDuration: TimeInterval = 8

    private var tasks: [String: Task<Void, Never>] = [:]

    private init() {}

    // 이미 이 주문을 진행 중이면 아무것도 하지 않는다(홈 화면 폴링·주문 상세 진입 등 여러
    // 곳에서 중복 호출해도 안전). 이미 끝났거나(픽업 완료) 취소·환불된 주문도 대상이 아니다.
    func scheduleIfNeeded(for order: Order) {
        let key = progressionKey(for: order)
        guard tasks[key] == nil else { return }
        guard order.status == .confirming || order.status == .making || order.status == .waitingPickup else { return }

        tasks[key] = Task { [weak self] in
            await self?.runProgression(pickupNumber: order.pickupNumber, storeName: order.storeName, confirmedAt: order.confirmedAt)
            self?.tasks[key] = nil
        }
    }

    private func progressionKey(for order: Order) -> String {
        "\(order.pickupNumber)-\(order.storeName)"
    }

    // confirmedAt 기준으로 각 단계가 끝나야 할 시각을 미리 계산해두고 그때까지만 잔여 시간을
    // 잔다. 이렇게 하면 앱을 껐다 켜서 이 스케줄러가 뒤늦게 다시 만들어지는 경우에도(주문은
    // LocalStore에 남아있다) 이미 지난 단계는 건너뛰고 올바른 단계부터 바로 이어진다.
    private func runProgression(pickupNumber: Int, storeName: String, confirmedAt: Date) async {
        let confirmingEnd = confirmedAt.addingTimeInterval(Self.confirmingDuration)
        await Self.sleepUntil(confirmingEnd)
        guard !Task.isCancelled,
              var order = LocalStore.shared.order(pickupNumber: pickupNumber, storeName: storeName),
              order.status == .confirming else { return }
        order.status = .making
        order.madeAt = confirmingEnd
        LocalStore.shared.updateOrder(order)
        await OrderLiveActivityController.update(for: order, queueCount: 2)

        let makingEnd = confirmingEnd.addingTimeInterval(Self.makingDuration)
        await Self.sleepUntil(makingEnd)
        guard !Task.isCancelled,
              var order = LocalStore.shared.order(pickupNumber: pickupNumber, storeName: storeName),
              order.status == .making else { return }
        order.status = .waitingPickup
        order.waitingAt = makingEnd
        LocalStore.shared.updateOrder(order)
        await OrderPushNotifier.scheduleIfNeeded(for: order)
        await OrderLiveActivityController.update(for: order)

        let waitingEnd = makingEnd.addingTimeInterval(Self.waitingPickupDuration)
        await Self.sleepUntil(waitingEnd)
        guard !Task.isCancelled,
              var order = LocalStore.shared.order(pickupNumber: pickupNumber, storeName: storeName),
              order.status == .waitingPickup else { return }
        order.status = .pickedUp
        order.pickedUpAt = waitingEnd
        LocalStore.shared.updateOrder(order)
        await OrderLiveActivityController.end(for: order)
    }

    private static func sleepUntil(_ date: Date) async {
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }
        try? await Task.sleep(for: .seconds(interval))
    }
}
