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

    init(repository: UserProfileRepository = AppContainer.shared.userProfileRepository) {
        self.repository = repository
    }

    func loadProfileIfNeeded() async {
        guard profile == nil else { return }
        profile = try? await repository.fetchProfile()
    }
}
