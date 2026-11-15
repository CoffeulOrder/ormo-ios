import Foundation

@Observable
final class NameInputViewModel {
    // 상태·문구: 닉네임 없음 · 이름만 받아요 · 1~20자
    static let maxLength = 20

    var name: String = ""
    var isValid: Bool { (1...Self.maxLength).contains(name.count) }

    func nameChanged(to newValue: String) {
        name = String(newValue.prefix(Self.maxLength))
    }

    func nextTapped() {
        guard isValid else { return }
        // TODO: 0.2.4 비밀번호 설정으로 이동
    }
}
