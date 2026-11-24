import ActivityKit
import Foundation

// 잠금 화면 실시간 현황(Live Activity)이 앱과 ORMOWidget 두 타겟 모두에서 같은 타입을 써야 해서
// 이 파일은 두 타겟 멤버십이 모두 켜져 있어야 한다 (Xcode File Inspector에서 ORMOWidget도 체크).
// Order 전체를 공유하지 않고 위젯이 실제로 필요한 값만 추려 별도로 정의했다.
struct OrderActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        enum Phase: String, Codable, Hashable {
            case confirming
            case making
            case waitingPickup
            case pickedUp
        }

        var phase: Phase
        // 주문 확인 중·만드는 중 단계에서만 쓰는 "내 앞에 N건" 안내. 그 외 단계에서는 nil.
        var queueCount: Int?
        // 픽업 대기 단계에서 "O시까지 받아주세요"에 쓰는 마감 시각.
        var pickupDeadline: Date?
    }

    let pickupNumber: Int
    let storeName: String
}
