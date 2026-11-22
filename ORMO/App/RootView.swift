import SwiftUI

struct RootView: View {
    @State private var isSplashFinished = false
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            // 1.1.1 매장 선택 화면이 아직 없어 임시로 RootTabView를 보여준다.
            RootTabView()
        } else if isSplashFinished {
            LoginView(onAuthenticated: { isLoggedIn = true })
        } else {
            SplashView(onFinished: { isSplashFinished = true })
        }
    }
}

#Preview {
    RootView()
}
