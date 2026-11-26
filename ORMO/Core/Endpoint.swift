import Foundation

struct Endpoint {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
    }

    let method: Method
    let path: String
    let queryItems: [URLQueryItem]
    let body: (any Encodable)?
    // Bearer 헤더를 붙일지. 로그인·회원가입·인증코드 발송처럼 토큰이 없는 경로는 false.
    let requiresAuth: Bool
    // 주문 생성처럼 서버가 중복 요청 방지를 위해 요구하는 키.
    let idempotencyKey: String?

    init(
        method: Method,
        path: String,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true,
        idempotencyKey: String? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.body = body
        self.requiresAuth = requiresAuth
        self.idempotencyKey = idempotencyKey
    }
}
