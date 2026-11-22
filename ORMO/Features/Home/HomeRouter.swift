import SwiftUI

enum HomeRoute: Hashable {
    case storeSelection
    case storeInfo(Store)
    case search([MenuItem])
    case menuOptions(MenuItem)
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
}
