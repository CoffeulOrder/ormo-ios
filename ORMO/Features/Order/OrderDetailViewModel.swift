import Foundation

@Observable
final class OrderDetailViewModel {
    private(set) var order: Order

    private let repository: OrderRepository
    private let autoProgress: Bool
    private var progressionTask: Task<Void, Never>?

    init(pickupNumber: Int, storeName: String, repository: OrderRepository = MockOrderRepository()) {
        self.repository = repository
        self.order = .mock(pickupNumber: pickupNumber, storeName: storeName)
        self.autoProgress = true
    }

    // 프리뷰에서 각 상태(확인 중/만드는 중/픽업 대기/매장 취소/픽업 완료)를 바로 확인하기 위한 생성자.
    // 자동 진행 Task는 걸지 않는다 — 특정 상태를 고정해서 보는 게 목적이라서.
    init(order: Order, repository: OrderRepository = MockOrderRepository()) {
        self.repository = repository
        self.order = order
        self.autoProgress = false
    }

    func start() {
        guard autoProgress, progressionTask == nil else { return }
        progressionTask = Task {
            guard let fetched = try? await repository.fetchOrder(pickupNumber: order.pickupNumber, storeName: order.storeName) else { return }
            order = fetched
            await runProgression()
        }
    }

    // 매장이 주문을 처리하는 과정을 흉내 낸 Mock 진행: 4초마다 다음 단계로 자동 넘어간다.
    // 실제로는 매장 POS 상태 변경을 서버가 폴링·푸시로 알려주는 자리이며, Remote Repository가 대체한다.
    private func runProgression() async {
        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .making
        order.madeAt = Date()

        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .waitingPickup
        order.waitingAt = Date()

        try? await Task.sleep(for: .seconds(4))
        guard !Task.isCancelled else { return }
        order.status = .pickedUp
        order.pickedUpAt = Date()
    }

    // 사용자가 "주문 취소하기"를 눌렀을 때. 자동 진행 중이었다면 멈추고 취소 상태로 바꾼다.
    func cancelOrder() {
        progressionTask?.cancel()
        order.status = .userCancelled
        order.userCancelledAt = Date()
    }

    deinit {
        progressionTask?.cancel()
    }
}
