import Foundation
import Security

// 로그인 토큰 쌍을 Keychain에 보관한다. 앱을 지우기 전까지 유지되고, UserDefaults와 달리
// 기기 백업에 평문으로 노출되지 않는다.
final class TokenStore {
    static let shared = TokenStore()

    private let service = "com.orso.ormo.auth"
    private let accessTokenAccount = "accessToken"
    private let refreshTokenAccount = "refreshToken"

    private(set) var accessToken: String?
    private(set) var refreshToken: String?

    var isLoggedIn: Bool { accessToken != nil }

    private init() {
        accessToken = read(account: accessTokenAccount)
        refreshToken = read(account: refreshTokenAccount)
    }

    func save(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        write(accessToken, account: accessTokenAccount)
        write(refreshToken, account: refreshTokenAccount)
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
        delete(account: accessTokenAccount)
        delete(account: refreshTokenAccount)
    }

    private func write(_ value: String, account: String) {
        let query = baseQuery(account: account)
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = Data(value.utf8)
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func read(account: String) -> String? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(account: String) {
        SecItemDelete(baseQuery(account: account) as CFDictionary)
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
