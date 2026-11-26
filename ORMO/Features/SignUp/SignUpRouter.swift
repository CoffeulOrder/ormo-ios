import SwiftUI

enum SignUpRoute: Hashable {
    case email
    case verificationCode
    case profile
    case termsFullText(TermsDocument)
    case completion
}

@Observable
final class SignUpRouter {
    var path = NavigationPath()
    var userName: String = ""
    var resetEmail: String = ""
    // 0.2.1 이메일 화면에서 받은 가입용 이메일. 인증코드 재발송 등에 쓴다.
    var signUpEmail: String = ""
    var signUpPassword: String = ""
    // 인증코드 확인 성공 시 서버가 돌려준 토큰. 0.2.3 프로필 화면에서 계정을 실제로 만들 때 쓴다.
    var signUpVerificationToken: String = ""
    // 비밀번호 재설정 인증코드 확인 성공 시 서버가 돌려준 토큰.
    var resetVerificationToken: String = ""

    func push(_ route: SignUpRoute) {
        path.append(route)
    }
}
