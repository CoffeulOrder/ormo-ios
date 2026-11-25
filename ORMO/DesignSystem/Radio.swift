import SwiftUI

// Figma Radio 컴포넌트(여러 선택지 중 하나만 고를 때 쓰는 원형 컨트롤) 공통 구현.
// On: Fill/Brand 원 안에 지름이 전체의 절반인 흰 원을 더해 고리(도넛) 모양을 만든다 — 작은 점이 아니다.
// Off: 흰 배경 + Grey Opacity 300 테두리(비활성이면 Border/Default 테두리 + Neutral Weak 배경).
struct Radio: View {
    let isSelected: Bool
    var isEnabled: Bool = true
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Colors.fillBrand)
                Circle()
                    .fill(Colors.textOnFill)
                    .frame(width: size * 0.5, height: size * 0.5)
            } else {
                Circle()
                    .fill(isEnabled ? Color.clear : Colors.fillNeutralWeak)
                Circle()
                    .strokeBorder(isEnabled ? Colors.fieldBorder : Colors.borderDefault, lineWidth: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: Spacing.spacing16) {
        Radio(isSelected: false)
        Radio(isSelected: true)
        Radio(isSelected: false, isEnabled: false)
    }
    .padding()
}
