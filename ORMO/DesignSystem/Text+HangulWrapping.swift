import SwiftUI

extension Text {
    // 긴 한글 텍스트(주소·공지 등)가 어절 중간에서 끊기지 않도록 줄바꿈한다.
    // 기본 줄바꿈은 유니코드 규칙상 한글 음절을 한자처럼 다뤄 음절 경계에서도 끊을 수 있는데,
    // hangulWordPriority는 공백(어절 경계)을 음절 경계보다 우선시하도록 강제한다.
    init(hangulWrapping string: String) {
        var attributed = AttributedString(string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakStrategy = .hangulWordPriority
        attributed.paragraphStyle = paragraphStyle
        self.init(attributed)
    }
}
