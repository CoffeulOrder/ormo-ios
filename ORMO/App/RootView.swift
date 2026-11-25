import SwiftUI

struct RootView: View {
    @State private var isSplashFinished = false
    @State private var isLoggedIn = LocalStore.shared.loggedInEmail != nil
    @State private var pendingLoginToast: String?

    var body: some View {
        if !isSplashFinished {
            // 자동 로그인 이력이 있어도 스플래시는 앱을 켤 때마다 항상 먼저 보여준다.
            SplashView(onFinished: { isSplashFinished = true })
        } else if isLoggedIn {
            // 1.1.1 매장 선택 화면이 아직 없어 임시로 RootTabView를 보여준다.
            RootTabView(onLogout: { message in
                LocalStore.shared.logout()
                pendingLoginToast = message
                isLoggedIn = false
            })
        } else {
            LoginView(
                onAuthenticated: { isLoggedIn = true },
                pendingToastMessage: pendingLoginToast
            )
        }
    }
}

#Preview {
    RootView()
}
