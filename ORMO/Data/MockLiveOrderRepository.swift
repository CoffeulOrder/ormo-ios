import Foundation

// 실시간 주문 현황 데모용: 실제 결제·주문 접수 기능이 아직 없어서, 화면을 보고 있으면
// 주문 확인 중(8초) → 만드는 중(10초) → 픽업 대기(12초) → 사라짐(5초) 순서로 자동 반복한다.
// 각 단계 길이는 데모 시연용으로 짧게 잡은 값이고 실제 서비스 타이밍이 아니다.
struct MockLiveOrderRepository: LiveOrderRepository {
    func observeLiveOrder(storeName: String) -> AsyncStream<LiveOrder?> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    continuation.yield(
                        LiveOrder(pickupNumber: 27, storeName: storeName, stage: .confirming, queueCount: 3, pickupDeadlineText: "")
                    )
                    try? await Task.sleep(for: .seconds(8))
                    guard !Task.isCancelled else { break }

                    continuation.yield(
                        LiveOrder(pickupNumber: 27, storeName: storeName, stage: .making, queueCount: 2, pickupDeadlineText: "")
                    )
                    try? await Task.sleep(for: .seconds(10))
                    guard !Task.isCancelled else { break }

                    continuation.yield(
                        LiveOrder(pickupNumber: 27, storeName: storeName, stage: .readyForPickup, queueCount: 0, pickupDeadlineText: "13:30까지 받아주세요")
                    )
                    try? await Task.sleep(for: .seconds(12))
                    guard !Task.isCancelled else { break }

                    continuation.yield(nil)
                    try? await Task.sleep(for: .seconds(5))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
