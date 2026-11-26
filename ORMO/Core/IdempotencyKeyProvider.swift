import Foundation

// 주문 생성은 서버가 Idempotency-Key를 요구한다(같은 키로 재요청하면 같은 주문을 돌려준다).
// 결제까지 끝나지 않은 "같은 논리 주문"인 동안은 같은 키를 재사용하고, OD010(키 중복) 같은
// 완전히 새 주문이 필요한 상황에서만 discard() 후 다음 키를 새로 받는다.
final class IdempotencyKeyProvider {
    static let shared = IdempotencyKeyProvider()

    private var currentKey: String?

    func currentOrNewKey() -> String {
        if let currentKey { return currentKey }
        let newKey = UUID().uuidString
        currentKey = newKey
        return newKey
    }

    func discard() {
        currentKey = nil
    }
}
