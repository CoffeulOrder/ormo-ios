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
}
