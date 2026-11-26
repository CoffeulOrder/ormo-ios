import Foundation

// 서버 timestamp가 소수점 초 유무가 섞여 와서(응답 봉투의 timestamp는 있고, 주문 timeline은
// 없을 수 있음) 둘 다 시도한다. Remote 주문 관련 Repository들이 공유한다.
enum APIDateParsing {
    private static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let withoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func date(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        return withFractionalSeconds.date(from: raw) ?? withoutFractionalSeconds.date(from: raw)
    }
}
