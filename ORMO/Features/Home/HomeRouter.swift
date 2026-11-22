import SwiftUI

enum HomeRoute: Hashable {
    case storeSelection
    case storeInfo(Store)
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
}
