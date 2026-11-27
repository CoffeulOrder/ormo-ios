import Foundation

@Observable
final class SignUpProfileViewModel {
    enum Step {
        case name
        case password
        case passwordConfirmation
    }

    // 상태·문구: 닉네임 없음 · 이름만 받아요 · 1~10자
    static let nameMaxLength = 10
    static let passwordMinLength = 8

    var step: Step = .name

    var name: String = ""
    var password: String = ""
    var passwordConfirmation: String = ""
    var isPasswordVisible = false
    var isPasswordConfirmationVisible = false

    // 이름: 한글·영문만 허용(이름 중간 띄어쓰기는 허용). 앞뒤 공백은 오류 없이 잘라낸다.
    // 한글 조합 중(초성만 입력된 상태 등)에는 완성된 음절(가-힣)만 검사 대상이라 조합 중 글자는 걸러지지 않는다.
    private static let nameAllowedCharacters: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "a"..."z")
        set.insert(charactersIn: "A"..."Z")
        set.insert(charactersIn: "가"..."힣")
        set.formUnion(.whitespaces)
        return set
    }()

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }

    // 빈 값은 버튼이 이미 막아주므로 별도 경고가 필요 없고, 한글·영문이 아닌 글자가 있을 때만 경고를 띄운다.
    var hasInvalidNameCharacters: Bool {
        !name.isEmpty && name.unicodeScalars.contains { !Self.nameAllowedCharacters.contains($0) }
    }

    var isNameValid: Bool {
        !trimmedName.isEmpty && name.count <= Self.nameMaxLength && !hasInvalidNameCharacters
    }

    var hasMinLength: Bool { password.count >= Self.passwordMinLength }
    var hasLetterAndDigit: Bool {
        password.contains { $0.isLetter } && password.contains { $0.isNumber }
    }
    var isPasswordRulesSatisfied: Bool { hasMinLength && hasLetterAndDigit }

    // 확인 칸이 다르면: 비밀번호가 서로 달라요
    var isPasswordMismatched: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation != password
    }
    var isPasswordConfirmationValid: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation == password
    }

    var isCurrentStepValid: Bool {
        switch step {
        case .name: isNameValid
        case .password: isPasswordRulesSatisfied
        case .passwordConfirmation: isPasswordConfirmationValid
        }
    }

    func nameChanged(to newValue: String) {
        name = String(newValue.prefix(Self.nameMaxLength))
    }

    func confirmNameTapped() {
        guard isNameValid else { return }
        name = trimmedName
        step = .password
    }

    func confirmPasswordTapped() {
        guard isPasswordRulesSatisfied else { return }
        step = .passwordConfirmation
    }
}
