import SwiftUI

// Figma "295:4851 Live Activity · Lock Screen"의 "Illust"(60×60) 실측 좌표를 그대로 옮겼다.
// 메인 앱(ORMO/DesignSystem/LiveOrderIllustrationView)은 Lottie로 애니메이션하지만, 이 타겟은
// 위젯이라 Lottie를 새로 추가하지 않고, 시스템이 스냅샷으로 주기적으로만 다시 그리는 Live
// Activity 특성상 정지 그림 한 장으로도 충분해서 절대좌표로 조립한 정지 일러스트로 옮겼다.
struct LiveOrderIllustrationView: View {
    let phase: OrderActivityAttributes.ContentState.Phase

    // Figma "Coffee"(32c41.svg)의 방사형 그라데이션 색 그대로.
    private static let coffeeGradient = RadialGradient(
        colors: [
            Color(red: 0x7B / 255, green: 0x54 / 255, blue: 0x40 / 255),
            Color(red: 0x8F / 255, green: 0x66 / 255, blue: 0x4D / 255),
            Color(red: 0x9C / 255, green: 0x74 / 255, blue: 0x57 / 255),
            Color(red: 0xB8 / 255, green: 0x95 / 255, blue: 0x6F / 255),
            Color(red: 0xA9 / 255, green: 0x83 / 255, blue: 0x5F / 255),
        ],
        center: .center,
        startRadius: 0,
        endRadius: 15
    )

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch phase {
            case .confirming:
                printer
            case .making:
                cup(image: "LiveOrderCupEmpty", x: 6.61, y: 16.49, width: 46.875, height: 41.871)
                coffeeSurface
                item(image: "LiveOrderDrop", x: 22.58, y: 4.05, width: 9.74, height: 14.167)
            case .waitingPickup:
                cup(image: "LiveOrderCupFull", x: 6.56, y: 16.76, width: 46.875, height: 41.484)
                item(image: "LiveOrderSteam1", x: 21.24, y: 0.11, width: 9.893, height: 14.913)
                item(image: "LiveOrderSteam2", x: 27.59, y: 8.09, width: 8.564, height: 9.155)
            case .pickedUp:
                cup(image: "LiveOrderCupFull", x: 6.56, y: 16.76, width: 46.875, height: 41.484)
            }
        }
        .frame(width: 60, height: 60)
        .accessibilityHidden(true)
    }

    private var printer: some View {
        Group {
            item(image: "LiveOrderPrinterBack", x: 11.24, y: 20.52, width: 41.292, height: 12.291)
            item(image: "LiveOrderPaper", x: 18.25, y: 6.18, width: 26.845, height: 25.444)
            item(image: "LiveOrderPrinterFront", x: 7.14, y: 28.06, width: 45.605, height: 30.188)
        }
    }

    // 컵 안쪽에 비친 커피 표면 — Figma 원본은 PNG 마스크 애니메이션이지만, 실제로는 타원
    // 하나(32c41.svg)를 커피색 그라데이션으로 채운 것뿐이라 네이티브 Shape로 그대로 옮겼다.
    private var coffeeSurface: some View {
        Ellipse()
            .fill(Self.coffeeGradient)
            .frame(width: 29.6173, height: 13.4807)
            .rotationEffect(.degrees(5.8))
            .frame(width: 31.967, height: 17.727)
            .offset(x: 6.61 + 3.62, y: 16.49 + 0.43)
    }

    private func cup(image: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        item(image: image, x: x, y: y, width: width, height: height)
    }

    private func item(image: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .offset(x: x, y: y)
    }
}

#Preview {
    HStack(spacing: 16) {
        LiveOrderIllustrationView(phase: .confirming)
        LiveOrderIllustrationView(phase: .making)
        LiveOrderIllustrationView(phase: .waitingPickup)
        LiveOrderIllustrationView(phase: .pickedUp)
    }
    .padding()
    .background(Color.white)
}
