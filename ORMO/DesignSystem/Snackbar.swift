import SwiftUI

// Figma "Snackbar" — 행동의 결과를 3~5초 보여주는 하단 알림. 아이콘+문구만 있는 변형(Positive/Critical).
struct Snackbar: View {
    enum Tone: Equatable {
        case positive
        case critical
    }

    let message: String
    let tone: Tone

    var body: some View {
        HStack(spacing: Spacing.spacing12) {
            icon
            Text(message)
                .typography(Typography.bodyMdSemibold)
                .foregroundStyle(Colors.textOnFill)
        }
        .padding(.leading, Spacing.spacing16)
        .padding(.trailing, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
        .background(Colors.fillNeutral)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var icon: some View {
        switch tone {
        case .critical:
            Image(.alertCircleIcon)
                .resizable()
                .frame(width: 24, height: 24)
        case .positive:
            // Figma엔 Positive 변형 아이콘 디자인이 따로 없어, Critical과 같은 흰 원 위 아이콘 틀에
            // 성공 색상·체크 아이콘을 맞춰 넣었다(OrmoSymbolView 배지와 같은 조합 방식).
            Circle()
                .fill(Colors.fillSuccess)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(.badgeCheckIcon)
                        .resizable()
                        .frame(width: 14, height: 14)
                )
        }
    }
}

#Preview {
    VStack(spacing: Spacing.spacing16) {
        Snackbar(message: "주문을 취소했어요", tone: .positive)
        Snackbar(message: "주문이 접수되어 취소할 수 없어요", tone: .critical)
    }
    .padding()
    .background(Colors.backgroundDefault)
}
