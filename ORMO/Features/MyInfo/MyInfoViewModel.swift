import Foundation

@Observable
final class MyInfoViewModel {
    private(set) var profile: UserProfile?
    var isLogoutDialogVisible = false
    var isWithdrawBlockedDialogVisible = false

    private static let ongoingStatuses: Set<OrderStatus> = [.confirming, .making, .waitingPickup]

    var ongoingOrderCount: Int {
        LocalStore.shared.orders.filter { Self.ongoingStatuses.contains($0.status) }.count
    }

    var hasOngoingOrders: Bool { ongoingOrderCount > 0 }

    private let repository: UserProfileRepository
    private let authRepository: AuthRepository

    init(
        repository: UserProfileRepository = AppContainer.shared.userProfileRepository,
        authRepository: AuthRepository = AppContainer.shared.authRepository
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }

    func loadProfileIfNeeded() async {
        guard profile == nil else { return }
        profile = try? await repository.fetchProfile()
    }

    func logout() async {
        // 서버 로그아웃이 실패해도(네트워크 등) 기기에서는 항상 로그아웃된 것처럼 동작해야 한다.
        try? await authRepository.logout()
    }
}
