import ActivityKit
import Foundation

// 주문 상세 화면의 상태 진행(OrderDetailViewModel)에 맞춰 잠금 화면 Live Activity를 시작·갱신·종료한다.
// "잠금 화면 실시간 현황"을 켤지 끌지는 기기 설정 앱(Live Activity 권한)이 유일한 기준이다 —
// 앱이 따로 저장하는 값은 없다. OS가 막고 있으면 아예 시작하지 않고, 대신 OrderPushNotifier가
// 대체 알림을 보낸다.
enum OrderLiveActivityController {
    private static let pickupWindowMinutes = 20
    // 픽업 완료 뒤 Figma 명세(15~30분) 안에서 중간값으로 자동으로 사라지게 한다.
    private static let dismissAfterPickupMinutes = 20

    private static func currentActivity(pickupNumber: Int) -> Activity<OrderActivityAttributes>? {
        Activity<OrderActivityAttributes>.activities.first { $0.attributes.pickupNumber == pickupNumber }
    }

    // OrderPushNotifier가 "이 주문은 이미 Live Activity로 보여주고 있으니 대체 알림을 또 보낼
    // 필요는 없다"를 판단하는 데 쓴다.
    static func isActive(pickupNumber: Int) -> Bool {
        currentActivity(pickupNumber: pickupNumber) != nil
    }

    static func start(for order: Order, queueCount: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] 시작 안 함: OS가 Live Activity를 허용하지 않음 (ActivityAuthorizationInfo().areActivitiesEnabled == false)")
            return
        }
        guard currentActivity(pickupNumber: order.pickupNumber) == nil else {
            print("[LiveActivity] 시작 안 함: 이 주문(\(order.pickupNumber))은 이미 Activity가 떠 있음")
            return
        }

        let attributes = OrderActivityAttributes(pickupNumber: order.pickupNumber, storeName: order.storeName)
        let state = OrderActivityAttributes.ContentState(phase: .confirming, queueCount: queueCount, pickupDeadline: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
            print("[LiveActivity] 시작됨: id=\(activity.id)")
        } catch {
            print("[LiveActivity] Activity.request 실패: \(error)")
        }
    }

    static func update(for order: Order, queueCount: Int? = nil) async {
        guard let activity = currentActivity(pickupNumber: order.pickupNumber) else { return }
        guard let phase = phase(for: order.status) else {
            await end(for: order)
            return
        }

        let pickupDeadline: Date? = phase == .waitingPickup
            ? Calendar.current.date(byAdding: .minute, value: pickupWindowMinutes, to: order.waitingAt ?? Date())
            : nil
        let state = OrderActivityAttributes.ContentState(phase: phase, queueCount: queueCount, pickupDeadline: pickupDeadline)

        // 픽업 대기로 바뀌는 순간은 Figma 명세상 "알림으로 화면 켜짐·소리"가 나야 하는 유일한 단계라
        // alertConfiguration을 함께 준다. 나머지 단계는 조용히 갱신한다.
        if phase == .waitingPickup {
            let alert = AlertConfiguration(title: "음료가 준비됐어요", body: "\(order.storeName)에서 수령해 주세요", sound: .default)
            await activity.update(.init(state: state, staleDate: nil), alertConfiguration: alert)
        } else {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func end(for order: Order) async {
        guard let activity = currentActivity(pickupNumber: order.pickupNumber) else { return }

        if order.status == .pickedUp {
            let state = OrderActivityAttributes.ContentState(phase: .pickedUp, queueCount: nil, pickupDeadline: nil)
            let dismissAt = Calendar.current.date(byAdding: .minute, value: dismissAfterPickupMinutes, to: Date()) ?? Date()
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .after(dismissAt))
        } else {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private static func phase(for status: OrderStatus) -> OrderActivityAttributes.ContentState.Phase? {
        switch status {
        case .confirming: .confirming
        case .making: .making
        case .waitingPickup: .waitingPickup
        case .pickedUp: .pickedUp
        case .cancelled, .userCancelled, .refunded, .unclaimed: nil
        }
    }
}
