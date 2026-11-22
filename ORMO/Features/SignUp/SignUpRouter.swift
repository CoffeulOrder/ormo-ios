import SwiftUI

enum SignUpRoute: Hashable {
    case email
    case verificationCode
    case profile
    case termsFullText(TermsDocument)
    case completion
}

@Observable
final class SignUpRouter {
    var path = NavigationPath()
    var userName: String = ""
    var resetEmail: String = ""

    func push(_ route: SignUpRoute) {
        path.append(route)
    }
}
