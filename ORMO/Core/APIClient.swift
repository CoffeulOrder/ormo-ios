import Foundation

// 서버 공통 응답 봉투를 까서 돌려주는 단일 네트워크 진입점. 401을 받으면 refreshToken으로
// 한 번 갱신을 시도하고, 그래도 안 되면(AUTH_003 등) 토큰을 지우고 .sessionExpired를 던진다 —
// 화면 쪽은 이 에러만 보고 로그인 화면으로 돌려보내면 된다.
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let tokenStore: TokenStore

    init(baseURL: URL = AppConfig.apiBaseURL, session: URLSession = .shared, tokenStore: TokenStore = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    @discardableResult
    func send<T: Decodable>(_ endpoint: Endpoint, decodingDataAs type: T.Type) async throws -> T {
        let data = try await performWithRefresh(endpoint)
        let envelope = try decodeEnvelope(APIEnvelope<T>.self, from: data)
        guard envelope.code == "SUCCESS", let payload = envelope.data else {
            throw APIError.server(code: envelope.code, message: envelope.message, status: envelope.status)
        }
        return payload
    }

    // data 필드가 없는 응답(로그아웃 등)용.
    func send(_ endpoint: Endpoint) async throws {
        let data = try await performWithRefresh(endpoint)
        let envelope = try decodeEnvelope(APIEnvelope<EmptyAPIData>.self, from: data)
        guard envelope.code == "SUCCESS" else {
            throw APIError.server(code: envelope.code, message: envelope.message, status: envelope.status)
        }
    }

    private func performWithRefresh(_ endpoint: Endpoint) async throws -> Data {
        let (data, response) = try await perform(endpoint)
        guard let http = response as? HTTPURLResponse else { return data }

        guard http.statusCode == 401, endpoint.requiresAuth else { return data }

        guard await refreshAccessToken() else {
            tokenStore.clear()
            throw APIError.sessionExpired
        }
        let (retryData, _) = try await perform(endpoint)
        return retryData
    }

    private func perform(_ endpoint: Endpoint) async throws -> (Data, URLResponse) {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth, let accessToken = tokenStore.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let idempotencyKey = endpoint.idempotencyKey {
            request.setValue(idempotencyKey, forHTTPHeaderField: "Idempotency-Key")
        }
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }
    }

    // refreshToken 자체를 요구 경로 없이(requiresAuth: false) 호출하므로, 이 안에서 401이 나도
    // performWithRefresh가 다시 refreshAccessToken을 부르지 않는다(무한 재시도 방지).
    private func refreshAccessToken() async -> Bool {
        guard let refreshToken = tokenStore.refreshToken else { return false }

        struct RefreshRequestBody: Encodable { let refreshToken: String }
        struct RefreshResponseData: Decodable { let accessToken: String; let refreshToken: String }

        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/auth/refresh",
            body: RefreshRequestBody(refreshToken: refreshToken),
            requiresAuth: false
        )

        do {
            let (data, _) = try await perform(endpoint)
            let envelope = try decodeEnvelope(APIEnvelope<RefreshResponseData>.self, from: data)
            guard envelope.code == "SUCCESS", let payload = envelope.data else { return false }
            tokenStore.save(accessToken: payload.accessToken, refreshToken: payload.refreshToken)
            return true
        } catch {
            return false
        }
    }

    private func decodeEnvelope<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
