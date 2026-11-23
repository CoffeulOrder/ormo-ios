import SwiftUI

// 결제 확인 중·실패·만료 화면에서 공통으로 쓰는 ORMO 심볼(컵+김). Figma "ORMO Symbol" 박스(100.54×128)
// 좌표를 그대로 옮겼다. badge가 있으면 오른쪽 아래에 상태 배지(성공·실패·시계 등)를 겹쳐 보여준다.
struct OrmoSymbolView: View {
    struct Badge {
        let color: Color
        let icon: ImageResource
        let iconSize: CGFloat
    }

    var cupColor: Color = Colors.fillBrand
    var badge: Badge?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(.ormoCup)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(cupColor)
                .frame(width: 97.41, height: 86.11)
                .offset(x: 1.55, y: 40.35)

            Image(.ormoSteamL)
                .resizable()
                .frame(width: 19.97, height: 26.7)
                .offset(x: 35.47, y: 13.16)

            Image(.ormoSteamR)
                .resizable()
                .frame(width: 26.17, height: 36.59)
                .offset(x: 57.49, y: 1.57)

            if let badge {
                Circle()
                    .fill(badge.color)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .overlay(
                        Image(badge.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Colors.textOnFill)
                            .frame(width: badge.iconSize, height: badge.iconSize)
                    )
                    .frame(width: 36, height: 36)
                    .offset(x: 62, y: 92)
            }
        }
        .frame(width: 100.54, height: 128, alignment: .topLeading)
    }
}

#Preview {
    VStack(spacing: Spacing.spacing40) {
        OrmoSymbolView()
        OrmoSymbolView(badge: .init(color: Colors.fillDanger, icon: .closeIconSolid, iconSize: 20))
        // Figma hex #001936 — 이 심볼 전용 고정 색이라 디자인시스템 토큰으로 추상화하지 않았다.
        OrmoSymbolView(cupColor: Color(red: 0 / 255, green: 25 / 255, blue: 54 / 255), badge: .init(color: Colors.fillNeutral, icon: .clockIcon, iconSize: 20))
    }
}
