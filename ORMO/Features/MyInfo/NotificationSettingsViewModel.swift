import ActivityKit
import UIKit
import UserNotifications

// 이 화면의 토글 3개는 더 이상 앱이 따로 값을 저장하지 않는다 — 기기(OS)의 실제 권한 상태가
// 유일한 진실이다. 예전에는 UserDefaults에 "켜짐/꺼짐"을 따로 저장해서, OS 권한을 꺼도 앱은
// 계속 "알림을 보내도 되는 상태"로 착각하거나 반대로 OS에서 다시 켜도 앱이 따로 꺼둔 값 때문에
// 안 보내는 식으로 둘이 어긋날 수 있었다. 지금은 토글을 탭하면: 아직 한 번도 물어본 적 없으면
// (.notDetermined) 그 자리에서 OS 권한 팝업을 띄우고, 이미 한 번이라도 답한 뒤라면(허용·거부
// 어느 쪽이든 OS가 다시 묻지 않으므로) 설정 앱으로 보낸다. 설정 앱에서 바꾸고 돌아오면
// scenePhase가 .active로 바뀔 때 다시 읽어서 화면에 바로 반영된다.
@Observable
final class NotificationSettingsViewModel {
    private(set) var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined

    var isNotificationOn: Bool {
        switch notificationAuthorizationStatus {
        case .authorized, .provisional, .ephemeral: true
        case .notDetermined, .denied: false
        @unknown default: false
        }
    }
    var isNotificationDenied: Bool { notificationAuthorizationStatus == .denied }

    // Live Activity는 OS에 "권한을 물어보는" API 자체가 없다 — 기기 설정 앱에서만 켜고 끌 수
    // 있어서, 요청 로직 없이 항상 이 값을 그대로 보여주기만 한다.
    var isLiveActivityOn: Bool { ActivityAuthorizationInfo().areActivitiesEnabled }

    var isLocationOn: Bool {
        let status = LocationPermissionManager.shared.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    var isLocationDenied: Bool { LocationPermissionManager.shared.isDenied }

    func refreshSystemNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationAuthorizationStatus = settings.authorizationStatus
    }

    // 주문 알림 토글: 아직 안 물어봤으면 그 자리에서 OS 권한 팝업, 이미 답한 뒤라면 설정 앱으로.
    func notificationToggled() {
        guard notificationAuthorizationStatus == .notDetermined else {
            openSystemSettingsTapped()
            return
        }
        Task {
            _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await refreshSystemNotificationStatus()
        }
    }

    // Live Activity는 항상 설정 앱으로 보낸다(요청 팝업이 없으므로).
    func liveActivityToggled() {
        openSystemSettingsTapped()
    }

    // 위치 토글: 아직 안 물어봤으면 iOS 기본 위치 접근 동의 팝업, 이미 답한 뒤라면 설정 앱으로.
    func locationToggled() {
        guard LocationPermissionManager.shared.authorizationStatus == .notDetermined else {
            openSystemSettingsTapped()
            return
        }
        LocationPermissionManager.shared.requestAuthorizationIfNeeded()
    }

    func openSystemSettingsTapped() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
