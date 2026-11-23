import Foundation

@Observable
final class MyInfoViewModel {
    private(set) var profile: UserProfile?
    var isLogoutDialogVisible = false
    var isWithdrawBlockedDialogVisible = false

    // Mock: 진행 중인 주문이 없다고 가정해 탈퇴 안내 화면으로 바로 이어지게 한다.
    // 실제로는 서버가 진행 중인 주문 수를 알려줘야 판단할 수 있다.
    let hasOngoingOrders = false

    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = MockUserProfileRepository()) {
        self.repository = repository
    }

    func loadProfileIfNeeded() async {
        guard profile == nil else { return }
        profile = try? await repository.fetchProfile()
    }
}
