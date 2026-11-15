import Foundation

@Observable
final class NameInputViewModel {
    // 상태·문구: 닉네임 없음 · 이름만 받아요 · 1~20자
    static let maxLength = 20
    private static let allowedCharacters = CharacterSet.letters.union(.whitespaces)

    var name: String = ""

    // 빈 값은 "다음" 버튼이 이미 막아주므로 별도 경고가 필요 없고,
    // 첫 글자 공백·특수문자처럼 형식이 잘못된 경우에만 경고를 띄운다.
    var hasInvalidCharacters: Bool {
        guard let first = name.first else { return false }
        if first == " " { return true }
        return name.unicodeScalars.contains { !Self.allowedCharacters.contains($0) }
    }

    var isValid: Bool {
        (1...Self.maxLength).contains(name.count) && !hasInvalidCharacters
    }

    func nameChanged(to newValue: String) {
        name = String(newValue.prefix(Self.maxLength))
    }
}
