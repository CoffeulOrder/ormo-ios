import Foundation

// 서버 공통 응답 봉투: {timestamp, status, code, message, data?, errors?}
// status는 HTTP 상태와 별도의 본문 상태값이라 문자열/숫자 어느 쪽으로 와도 그대로 받을 수 있게 둔다.
struct APIEnvelope<T: Decodable>: Decodable {
    let timestamp: String
    let status: String
    let code: String
    let message: String
    let data: T?
    let errors: [APIFieldError]?

    private enum CodingKeys: String, CodingKey {
        case timestamp, status, code, message, data, errors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        code = try container.decode(String.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        // 오류 응답의 data는 성공 응답과 모양이 다를 수 있다(예: AUTH_002 계정 잠김은
        // {lockedUntil}을 돌려준다). SUCCESS가 아닐 때 T로 디코딩을 시도하면 그 모양 차이
        // 때문에 디코딩 자체가 실패해서, 진짜 원인(AUTH_002 등)이 "응답 디코딩 실패"로
        // 가려져 버린다. 실패 응답의 data는 어차피 호출하는 쪽에서 쓰지 않으니 무시한다.
        data = code == "SUCCESS" ? try container.decodeIfPresent(T.self, forKey: .data) : nil
        errors = try container.decodeIfPresent([APIFieldError].self, forKey: .errors)

        if let statusString = try? container.decode(String.self, forKey: .status) {
            status = statusString
        } else {
            status = String(try container.decode(Int.self, forKey: .status))
        }
    }
}

struct APIFieldError: Decodable {
    let field: String
    let reason: String
}

// data가 없는 응답(예: 로그아웃)을 디코딩할 때 쓰는 자리표시자.
struct EmptyAPIData: Decodable {}

enum APIError: Error {
    case invalidURL
    case transport(Error)
    case decoding(Error)
    // 서버가 code != "SUCCESS"로 응답한 경우. code로 구체적인 처리를 분기한다(AUTH_003, U004, OD006 등).
    case server(code: String, message: String, status: String)
    // 401 이후 토큰 재발급까지 실패한 경우. 상위 레이어가 로그인 화면으로 돌려보내야 한다.
    case sessionExpired
}

extension APIError {
    static let authRefreshFailedCode = "AUTH_003"

    var serverCode: String? {
        if case let .server(code, _, _) = self { return code }
        return nil
    }

    var serverMessage: String? {
        if case let .server(_, message, _) = self { return message }
        return nil
    }
}
