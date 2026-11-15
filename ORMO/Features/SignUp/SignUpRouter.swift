import SwiftUI

enum SignUpRoute: Hashable {
    case email
    case verificationCode
    case nameInput
    case passwordSetup
}

@Observable
final class SignUpRouter {
    var path = NavigationPath()

    func push(_ route: SignUpRoute) {
        path.append(route)
    }
}
