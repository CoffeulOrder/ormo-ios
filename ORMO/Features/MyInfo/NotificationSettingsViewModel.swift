import UIKit
import UserNotifications

@Observable
final class NotificationSettingsViewModel {
    private enum DefaultsKey {
        static let isOrderNotificationEnabled = "notificationSettings.isOrderNotificationEnabled"
        static let isLockScreenLiveStatusEnabled = "notificationSettings.isLockScreenLiveStatusEnabled"
        static let isLocationEnabled = "notificationSettings.isLocationEnabled"
    }

    // 주문 상태가 바뀔 때 알림을 보내야 하는 다른 코드(OrderPushNotifier 등)가, 화면을 띄우지 않고도
    // 저장된 알림 설정을 바로 읽을 수 있도록 하는 정적 접근자.
    static var isOrderNotificationEnabledSetting: Bool {
        UserDefaults.standard.object(forKey: DefaultsKey.isOrderNotificationEnabled) as? Bool ?? true
    }
    static var isLockScreenLiveStatusEnabledSetting: Bool {
        UserDefaults.standard.object(forKey: DefaultsKey.isLockScreenLiveStatusEnabled) as? Bool ?? true
    }

    // Switch는 저장 버튼 없이 바로 반영돼야 하므로, 바뀔 때마다 즉시 UserDefaults에 적는다.
    var isOrderNotificationEnabled: Bool {
        didSet { UserDefaults.standard.set(isOrderNotificationEnabled, forKey: DefaultsKey.isOrderNotificationEnabled) }
    }
    var isLockScreenLiveStatusEnabled: Bool {
        didSet { UserDefaults.standard.set(isLockScreenLiveStatusEnabled, forKey: DefaultsKey.isLockScreenLiveStatusEnabled) }
    }
    var isLocationEnabled: Bool {
        didSet { UserDefaults.standard.set(isLocationEnabled, forKey: DefaultsKey.isLocationEnabled) }
    }
    // 설치 직후(알림 권한을 아직 한 번도 물어본 적 없는 .notDetermined) 상태는 "꺼져 있다"가
    // 아니라 "아직 안 물어봤다"이므로 배너를 띄우지 않는다. 실제로 사용자가 거부(.denied)했을 때만
    // 설정 앱으로 안내한다.
    private(set) var isSystemNotificationDenied = false
    private(set) var isSystemLocationDenied = false

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isOrderNotificationEnabled = defaults.object(forKey: DefaultsKey.isOrderNotificationEnabled) as? Bool ?? true
        isLockScreenLiveStatusEnabled = defaults.object(forKey: DefaultsKey.isLockScreenLiveStatusEnabled) as? Bool ?? true
        isLocationEnabled = defaults.object(forKey: DefaultsKey.isLocationEnabled) as? Bool ?? true
    }

    func refreshSystemNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isSystemNotificationDenied = settings.authorizationStatus == .denied
    }

    func refreshSystemLocationStatus() {
        isSystemLocationDenied = LocationPermissionManager.shared.isDenied
    }

    // 주문 알림을 켤 때 OS 권한을 아직 묻지 않은 상태라면, 토글이 실제로 알림을 받을 수 있도록
    // 바로 권한 요청까지 이어준다. 이미 거부된 상태라면 토글만 켜두고(값은 보존) 안내 배너로 설정 앱을
    // 유도한다.
    func orderNotificationToggled(to isEnabled: Bool) {
        isOrderNotificationEnabled = isEnabled
        guard isEnabled else { return }
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            }
            await refreshSystemNotificationStatus()
        }
    }

    // 위치 사용을 켤 때 OS 권한을 아직 묻지 않은 상태라면 iOS 기본 위치 접근 동의 팝업으로 이어준다.
    // 이미 거부된 상태라면 토글만 켜두고(값은 보존) 안내 배너로 설정 앱을 유도한다.
    func locationToggled(to isEnabled: Bool) {
        isLocationEnabled = isEnabled
        guard isEnabled else { return }
        LocationPermissionManager.shared.requestAuthorizationIfNeeded()
        refreshSystemLocationStatus()
    }

    func openSystemSettingsTapped() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
