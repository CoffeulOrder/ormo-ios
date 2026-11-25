import SwiftUI

// Figma Checkbox 컴포넌트(Circle 모양, 0개 이상 선택·온오프 겸용) 공통 구현.
// On: Fill/Brand 원 + 흰 체크. Off: 테두리만(Grey Opacity 300), 체크 표시 없음.
// 비활성이면 On은 Neutral Weak 배경, Off는 Border/Default 테두리로 바뀐다.
struct Checkbox: View {
    let isSelected: Bool
    var isEnabled: Bool = true
    var size: CGFloat = 20

    var body: some View {
        Circle()
            .fill(fillColor)
            .overlay {
                if !isSelected {
                    Circle()
                        .strokeBorder(isEnabled ? Colors.fieldBorder : Colors.borderDefault, lineWidth: 2)
                }
            }
            .overlay {
                if isSelected {
                    Image(.checkboxMark)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Colors.textOnFill)
                        .frame(width: size * 16 / 20, height: size * 16 / 20)
                }
            }
            .frame(width: size, height: size)
    }

    private var fillColor: Color {
        guard isSelected else { return Color.clear }
        return isEnabled ? Colors.fillBrand : Colors.fillNeutralWeak
    }
}

#Preview {
    VStack(spacing: Spacing.spacing16) {
        Checkbox(isSelected: false)
        Checkbox(isSelected: true)
        Checkbox(isSelected: false, isEnabled: false)
    }
    .padding()
}
