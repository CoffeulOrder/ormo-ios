import UserNotifications

// Figma "4.5.2 푸시 알림 4종 · 실시간 현황을 끈 경우" — 잠금 화면 실시간 현황(Live Activity)을 꺼둔
// 사용자에게 주문 상태 변화를 대신 알려주는 일반 푸시 알림. 실시간 현황을 켜둔 사용자는 Live Activity
// 카드로 이미 보고 있으니 중복으로 울리지 않는다.
enum OrderPushNotifier {
    private static let pickupWindowMinutes = 20

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func scheduleIfNeeded(for order: Order) async {
        guard NotificationSettingsViewModel.isOrderNotificationEnabledSetting,
              !NotificationSettingsViewModel.isLockScreenLiveStatusEnabledSetting else { return }
        guard let content = content(for: order) else { return }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }

    private static func content(for order: Order) -> UNMutableNotificationContent? {
        let content = UNMutableNotificationContent()

        switch order.status {
        case .waitingPickup:
            let deadline = Calendar.current.date(byAdding: .minute, value: pickupWindowMinutes, to: order.waitingAt ?? Date()) ?? Date()
            content.title = "음료가 준비됐어요"
            content.body = "\(timeFormatter.string(from: deadline))까지 \(order.storeName)에서 수령하세요. 그 이후에는 폐기될 수 있어요"
        case .cancelled:
            content.title = "매장에서 주문을 취소했어요"
            content.body = "음료를 준비하는 데 문제가 생겼어요. 결제한 \(order.subtotalPrice.formatted())원은 환불해 드려요."
        case .refunded:
            content.title = "\(order.subtotalPrice.formatted())원을 환불했어요"
            content.body = "카드사에 따라 환불까지 3~5일 걸릴 수 있어요."
        case .confirming, .making, .pickedUp, .userCancelled, .unclaimed:
            return nil
        }

        content.sound = .default
        return content
    }
}
