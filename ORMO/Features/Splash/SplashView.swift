import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void = {}

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
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            onFinished()
        }
    }
}

#Preview {
    SplashView()
}
