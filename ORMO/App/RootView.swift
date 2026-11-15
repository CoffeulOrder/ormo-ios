import SwiftUI

struct RootView: View {
    @State private var isSplashFinished = false

    var body: some View {
        if isSplashFinished {
            LoginView()
        } else {
            SplashView(onFinished: { isSplashFinished = true })
        }
    }
}

#Preview {
    RootView()
}
