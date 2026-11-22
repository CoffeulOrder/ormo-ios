import Foundation

enum TermsDocument: Hashable {
    case serviceTerms
    case privacyPolicy

    var title: String {
        switch self {
        case .serviceTerms: "서비스 이용약관"
        case .privacyPolicy: "개인정보 수집·이용"
        }
    }

    // 정식 법무 문구가 아직 없어 Figma 자리채움 문구를 그대로 쓰고, 없는 쪽은 같은 형식으로 새로 썼다.
    var articles: [(heading: String, body: String)] {
        switch self {
        case .serviceTerms:
            [
                ("제1조 (목적)", "이 약관은 ORMO가 제공하는 캠퍼스 카페 미리 주문 서비스를 이용할 때 필요한 조건과 절차를 정해요."),
                ("제2조 (정의)", "‘서비스’는 앱에서 메뉴를 고르고 결제한 뒤 매장에서 받아 가는 미리 주문을 말해요. ‘회원’은 학교 이메일로 가입한 사람을 말해요."),
                ("제3조 (약관의 게시와 변경)", "약관은 앱의 [내 정보 > 약관 및 정책]에서 언제든 볼 수 있어요. 약관을 바꾸면 시행 전에 앱 안에서 알려요.")
            ]
        case .privacyPolicy:
            [
                ("제1조 (수집 항목)", "ORMO는 회원가입과 주문을 위해 이름, 학교 이메일, 주문 내역을 수집해요."),
                ("제2조 (이용 목적)", "수집한 정보는 본인 확인, 주문 처리, 고객 문의 응대에만 사용해요."),
                ("제3조 (보유 기간)", "회원 탈퇴 시 관련 법령에 따른 보관 의무가 없는 한 지체 없이 정보를 삭제해요.")
            ]
        }
    }
}
