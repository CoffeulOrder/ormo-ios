import SwiftUI

// Figma Typography 변수: 모든 스타일이 "크기/행간" px 고정값 쌍을 가진다. 행간은 굵기와
// 무관하게 크기별로 하나씩 정해지고(Regular·Medium·Semibold·Bold 전부 동일), 자간은 0이다.
// Pretendard가 아직 프로젝트에 번들되지 않아 시스템 폰트로 대체한다(이후 교체 시 .system(size:weight:)를
// .custom("Pretendard-...", size:)으로만 바꾸면 된다). 행간은 대체 폰트 상태에서도 Figma 고정값을
// 그대로 따른다 — 시스템 폰트의 기본 줄 간격은 이 값보다 좁아서, 적용하지 않으면 행간이
// 좁고 텍스트 사이 여백이 부족해 보인다.
struct TypographyStyle: Equatable {
    let size: CGFloat
    let weight: Font.Weight
    let lineHeight: CGFloat
}

enum Typography {
    static let display2xlSemibold = TypographyStyle(size: 72, weight: .semibold, lineHeight: 90)
    static let displaySmSemibold = TypographyStyle(size: 30, weight: .semibold, lineHeight: 38)
    static let displayXsSemibold = TypographyStyle(size: 24, weight: .semibold, lineHeight: 32)

    static let bodyXlBold = TypographyStyle(size: 20, weight: .bold, lineHeight: 30)
    static let bodyXlSemibold = TypographyStyle(size: 20, weight: .semibold, lineHeight: 30)
    static let bodyXlRegular = TypographyStyle(size: 20, weight: .regular, lineHeight: 30)

    static let bodyLgBold = TypographyStyle(size: 18, weight: .bold, lineHeight: 28)
    static let bodyLgSemibold = TypographyStyle(size: 18, weight: .semibold, lineHeight: 28)
    static let bodyLgMedium = TypographyStyle(size: 18, weight: .medium, lineHeight: 28)
    static let bodyLgRegular = TypographyStyle(size: 18, weight: .regular, lineHeight: 28)

    static let bodyMdBold = TypographyStyle(size: 16, weight: .bold, lineHeight: 24)
    static let bodyMdSemibold = TypographyStyle(size: 16, weight: .semibold, lineHeight: 24)
    static let bodyMdMedium = TypographyStyle(size: 16, weight: .medium, lineHeight: 24)
    static let bodyMdRegular = TypographyStyle(size: 16, weight: .regular, lineHeight: 24)

    static let bodySmBold = TypographyStyle(size: 14, weight: .bold, lineHeight: 20)
    static let bodySmSemibold = TypographyStyle(size: 14, weight: .semibold, lineHeight: 20)
    static let bodySmMedium = TypographyStyle(size: 14, weight: .medium, lineHeight: 20)
    static let bodySmRegular = TypographyStyle(size: 14, weight: .regular, lineHeight: 20)

    static let bodyXsBold = TypographyStyle(size: 12, weight: .bold, lineHeight: 18)
    static let bodyXsSemibold = TypographyStyle(size: 12, weight: .semibold, lineHeight: 18)
    static let bodyXsMedium = TypographyStyle(size: 12, weight: .medium, lineHeight: 18)
}

extension View {
    // Figma 행간을 그대로 반영한다. SwiftUI의 .lineSpacing()은 줄과 줄 사이에만 더해지고
    // 첫 줄 위·마지막 줄 아래에는 적용되지 않는다. 그래서 위아래에 남는 여백(extra)의 절반씩을
    // 패딩으로 더해 한 줄짜리 텍스트도 디자인과 같은 줄 높이를 갖게 한다. n줄짜리 텍스트는
    // (줄 사이 간격 extra × (n-1)) + (위아래 패딩 extra) = extra × n이 되어, 전체 블록 높이가
    // 정확히 "스타일의 lineHeight × 줄 수"와 일치한다.
    func typography(_ style: TypographyStyle) -> some View {
        let uiFont = UIFont.systemFont(ofSize: style.size, weight: style.weight.uiFontWeight)
        let extra = max(style.lineHeight - uiFont.lineHeight, 0)
        return self
            .font(.system(size: style.size, weight: style.weight))
            .lineSpacing(extra)
            .padding(.vertical, extra / 2)
    }
}

private extension Font.Weight {
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .black: .black
        case .heavy: .heavy
        case .bold: .bold
        case .semibold: .semibold
        case .medium: .medium
        case .regular: .regular
        case .light: .light
        case .thin: .thin
        case .ultraLight: .ultraLight
        default: .regular
        }
    }
}
