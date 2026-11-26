import Foundation

struct LocalAccount: Codable, Equatable {
    var email: String
    var password: String
    var name: String
    var schoolName: String
}

// 실제 서버가 생기기 전까지, 회원가입·로그인·주문을 "진짜처럼" 테스트할 수 있도록 기기에 남겨두는
// 전체 서비스 상태. 앱을 지우거나 시뮬레이터를 초기화하기 전까지 유지된다.
// 실제 서버가 생기면 이 타입 전체가 Remote Repository들로 교체되고, 각 Mock Repository는
// 이 저장소 대신 네트워크 호출을 하게 된다.
@Observable
final class LocalStore {
    static let shared = LocalStore()

    private static let defaultsKey = "localStore.state.v1"
    private static let demoAccount = LocalAccount(email: "ormo@eulji.ac.kr", password: "ormo1234", name: "가을", schoolName: "을지대학교")

    private(set) var accounts: [LocalAccount]
    private(set) var loggedInEmail: String?
    private(set) var orders: [Order]

    private struct State: Codable {
        var accounts: [LocalAccount] = []
        var loggedInEmail: String?
        var orders: [Order] = []
    }

    private init() {
        let state = Self.load()
        accounts = state.accounts
        loggedInEmail = state.loggedInEmail
        orders = state.orders
        seedDemoAccountIfNeeded()
    }

    // 기존에 알려져 있던 데모 계정(ormo@eulji.ac.kr / ormo1234)은 그대로 로그인되게 남겨둔다.
    private func seedDemoAccountIfNeeded() {
        guard !accounts.contains(where: { $0.email == Self.demoAccount.email }) else { return }
        accounts.append(Self.demoAccount)
        persist()
    }

    // MARK: Accounts

    var currentAccount: LocalAccount? {
        guard let loggedInEmail else { return nil }
        return account(for: loggedInEmail)
    }

    func account(for email: String) -> LocalAccount? {
        accounts.first { $0.email.lowercased() == email.lowercased() }
    }

    @discardableResult
    func register(email: String, password: String, name: String, schoolName: String) -> LocalAccount {
        let account = LocalAccount(email: email, password: password, name: name, schoolName: schoolName)
        accounts.removeAll { $0.email.lowercased() == email.lowercased() }
        accounts.append(account)
        loggedInEmail = account.email
        persist()
        return account
    }

    func login(email: String) {
        guard let account = account(for: email) else { return }
        loggedInEmail = account.email
        persist()
    }

    func logout() {
        loggedInEmail = nil
        persist()
    }

    func updatePassword(email: String, newPassword: String) {
        guard let index = accounts.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) else { return }
        accounts[index].password = newPassword
        persist()
    }

    func deleteAccount(email: String) {
        accounts.removeAll { $0.email.lowercased() == email.lowercased() }
        if loggedInEmail?.lowercased() == email.lowercased() {
            loggedInEmail = nil
        }
        persist()
    }

    // MARK: Orders

    func addOrder(_ order: Order) {
        orders.insert(order, at: 0)
        persist()
    }

    func order(orderId: Int) -> Order? {
        orders.first { $0.orderId == orderId }
    }

    func updateOrder(_ order: Order) {
        guard let index = orders.firstIndex(where: { $0.orderId == order.orderId }) else { return }
        orders[index] = order
        persist()
    }

    func nextPickupNumber() -> Int {
        (orders.map(\.pickupNumber).max() ?? 0) + 1
    }

    func nextOrderId() -> Int {
        (orders.map(\.orderId).max() ?? 0) + 1
    }

    // MARK: Persistence

    private func persist() {
        let state = State(accounts: accounts, loggedInEmail: loggedInEmail, orders: orders)
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    }

    private static func load() -> State {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let state = try? JSONDecoder().decode(State.self, from: data) else {
            return State()
        }
        return state
    }
}
