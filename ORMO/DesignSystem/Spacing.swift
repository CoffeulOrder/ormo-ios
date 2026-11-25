import CoreGraphics

enum Spacing {
    static let spacing0: CGFloat = 0
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40
    static let spacing48: CGFloat = 48
    static let spacing64: CGFloat = 64
    // Figma spacing 스케일(0~64)에는 없는 값이다. 일부 화면 상단 여백에 쓰이고 있어 그대로
    // 남겨 둔다 — 제거하려면 Figma 실측으로 48/64 중 어느 쪽이 맞는지 먼저 확인해야 한다.
    static let spacing56: CGFloat = 56
}

enum Radius {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let r10: CGFloat = 10
    static let md: CGFloat = 12
    static let r14: CGFloat = 14
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 999
}

// 컴포넌트 높이별 토큰 (docs/DESIGN_SYSTEM.md 1.3.1 Height).
enum Size {
    static let height2xs: CGFloat = 24
    static let heightXs: CGFloat = 32
    static let heightSm: CGFloat = 36
    static let heightMd: CGFloat = 40
    static let heightLg: CGFloat = 48
    static let heightXl: CGFloat = 56
    static let heightTextarea: CGFloat = 120
}
