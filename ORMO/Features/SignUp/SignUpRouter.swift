import SwiftUI

enum SignUpRoute: Hashable {
    case email
    case verificationCode
    case profile
    case completion
}

@Observable
final class SignUpRouter {
    var path = NavigationPath()
    var userName: String = ""

    func push(_ route: SignUpRoute) {
        path.append(route)
    }
}
