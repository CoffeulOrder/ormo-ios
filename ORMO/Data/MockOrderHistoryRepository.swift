import Foundation

struct MockOrderHistoryRepository: OrderHistoryRepository {
    func fetchOrderHistory() async throws -> [Order] {
        try? await Task.sleep(for: .seconds(0.3))
        return LocalStore.shared.orders
    }
}
