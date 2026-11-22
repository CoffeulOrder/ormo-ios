import SwiftUI

enum HomeRoute: Hashable {
    case storeSelection
    case storeInfo(Store)
    case search([MenuItem])
    case menuOptions(MenuItem)
    case cart
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
}
