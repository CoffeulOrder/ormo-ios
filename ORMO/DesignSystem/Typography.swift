import SwiftUI

// Pretendard가 아직 프로젝트에 번들되지 않아 시스템 폰트로 대체한다.
// Pretendard 추가 시 .system(size:weight:) 대신 .custom("Pretendard-...", size:)으로 교체한다.
enum Typography {
    static let displayXsSemibold = Font.system(size: 24, weight: .semibold)
    static let bodyLgSemibold = Font.system(size: 18, weight: .semibold)
    static let bodyMdRegular = Font.system(size: 16, weight: .regular)
    static let bodyMdMedium = Font.system(size: 16, weight: .medium)
    static let bodySmSemibold = Font.system(size: 14, weight: .semibold)
}
