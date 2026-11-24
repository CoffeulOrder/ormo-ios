import CoreLocation

// 권한 설정의 "내 위치 사용" 토글과 앱 첫 진입 시, 위치 권한이 아직 한 번도 결정되지 않았을 때
// (.notDetermined)만 iOS 기본 위치 접근 동의 팝업을 띄운다. 이미 허용·거부된 뒤에는 CLLocationManager가
// 다시 묻지 않으므로, 이 함수를 여러 곳에서 불러도 실제로는 설치 후 최초 1회만 뜬다.
@Observable
final class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationPermissionManager()

    private let manager = CLLocationManager()
    private(set) var authorizationStatus: CLAuthorizationStatus

    var isDenied: Bool { authorizationStatus == .denied || authorizationStatus == .restricted }

    private override init() {
        authorizationStatus = CLLocationManager().authorizationStatus
        super.init()
        manager.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        guard authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
