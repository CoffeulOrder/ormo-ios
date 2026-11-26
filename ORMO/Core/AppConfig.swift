import Foundation

enum AppConfig {
    static let apiBaseURL: URL = {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: string) else {
            fatalError("API_BASE_URL 설정이 없어요. Config/*.xcconfig 연결을 확인하세요.")
        }
        return url
    }()

    static let useMock: Bool =
        (Bundle.main.object(forInfoDictionaryKey: "USE_MOCK") as? String) == "YES"

    // Info.plist(CFBundleURLTypes)에 등록한 결제 복귀용 URL 스킴. PortOne 결제창(PaymentWebView)의
    // appScheme 파라미터에 그대로 넘긴다.
    static let portOneAppScheme = "com-orso-ormo-payment://"
}
