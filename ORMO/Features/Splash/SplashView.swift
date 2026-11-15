import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Colors.backgroundDefault
                .ignoresSafeArea()

            Image(.ormoLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 72)
                .offset(y: -119)
        }
    }
}

#Preview {
    SplashView()
}
