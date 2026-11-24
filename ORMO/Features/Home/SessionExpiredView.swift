import SwiftUI

// Figma "6.1.2 로그인 만료" — 세션이 끊겼을 때 콘텐츠 자리에 Skeleton을 깔아둔 채
// Dim + Alert Dialog로 재로그인을 안내한다. 장바구니는 그대로 유지된다는 걸 메시지로 알려준다.
struct SessionExpiredView: View {
    let onLoginTapped: () -> Void

    var body: some View {
        ZStack {
            SkeletonLoadingView()
            Colors.backgroundDim.ignoresSafeArea()
            AlertDialog(
                title: "다시 로그인해주세요",
                message: "보안을 위해 로그아웃됐어요.\n장바구니에 담긴 메뉴는 그대로 유지돼요.",
                secondaryTitle: nil,
                primaryTitle: "로그인하기",
                primaryAction: onLoginTapped
            )
        }
    }
}

#Preview {
    SessionExpiredView(onLoginTapped: {})
}
