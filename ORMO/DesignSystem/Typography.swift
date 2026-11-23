import SwiftUI

// Pretendard가 아직 프로젝트에 번들되지 않아 시스템 폰트로 대체한다.
// Pretendard 추가 시 .system(size:weight:) 대신 .custom("Pretendard-...", size:)으로 교체한다.
enum Typography {
    static let displayXsSemibold = Font.system(size: 24, weight: .semibold)
    static let bodyXlBold = Font.system(size: 20, weight: .bold)
    static let bodyXlSemibold = Font.system(size: 20, weight: .semibold)
    static let bodyXlRegular = Font.system(size: 20, weight: .regular)
    static let displaySmSemibold = Font.system(size: 30, weight: .semibold)
    static let display2xlSemibold = Font.system(size: 72, weight: .semibold)
    static let bodyLgSemibold = Font.system(size: 18, weight: .semibold)
    static let bodyLgBold = Font.system(size: 18, weight: .bold)
    static let bodyLgRegular = Font.system(size: 18, weight: .regular)
    static let bodyMdRegular = Font.system(size: 16, weight: .regular)
    static let bodyMdMedium = Font.system(size: 16, weight: .medium)
    static let bodyMdSemibold = Font.system(size: 16, weight: .semibold)
    static let bodySmRegular = Font.system(size: 14, weight: .regular)
    static let bodySmMedium = Font.system(size: 14, weight: .medium)
    static let bodySmSemibold = Font.system(size: 14, weight: .semibold)
    static let bodySmBold = Font.system(size: 14, weight: .bold)
    static let bodyXsMedium = Font.system(size: 12, weight: .medium)
    static let bodyXsSemibold = Font.system(size: 12, weight: .semibold)
    static let bodyXsBold = Font.system(size: 12, weight: .bold)
}
