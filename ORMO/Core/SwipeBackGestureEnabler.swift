import SwiftUI
import UIKit

// 화면마다 시스템 내비게이션 바를 숨기고 Figma의 커스텀 상단 바를 쓰다 보니, iOS가 기본 뒤로가기
// 버튼이 없다고 판단해 화면 가장자리 스와이프 뒤로가기 제스처까지 함께 꺼버린다. 네비게이션
// 컨트롤러의 제스처를 직접 다시 켜고 delegate를 비워, 커스텀 버튼 유무와 상관없이 애플 기본 앱과
// 똑같이 가장자리 스와이프로 항상 되돌아갈 수 있게 한다.
private struct SwipeBackGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let gesture = uiViewController.navigationController?.interactivePopGestureRecognizer else { return }
            gesture.isEnabled = true
            gesture.delegate = nil
        }
    }
}

extension View {
    func enableSwipeBackGesture() -> some View {
        background(SwipeBackGestureEnabler())
    }
}
