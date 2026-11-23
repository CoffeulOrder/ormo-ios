import SwiftUI

enum HomeRoute: Hashable {
    case storeSelection
    case storeInfo(Store)
    case search([MenuItem])
    case menuOptions(MenuItem)
    case cart
    // attemptId: 같은 결제수단·금액으로 재시도하면 값이 완전히 같아져서, NavigationPath가
    // "이전 시도와 같은 화면"으로 오인해 이미 결과가 나온 화면을 그대로 재사용해버린다
    // (그래서 로딩 화면이 멈춰 보였다). 매 시도마다 새 UUID를 넣어 항상 고유한 값이 되게 한다.
    case paymentProcessing(attemptId: UUID, paymentMethod: PaymentMethod, totalPrice: Int, storeName: String)
    case paymentFailure(attemptId: UUID, paymentMethod: PaymentMethod, totalPrice: Int, storeName: String)
    case paymentExpired
    case orderComplete(pickupNumber: Int, storeName: String, queueCount: Int)
    case orderDetail(pickupNumber: Int, storeName: String)
    case receipt(pickupNumber: Int, storeName: String, totalPrice: Int, paidAt: Date)
    case myInfo
    case changePassword(email: String)
    case termsAndPolicy
    case termsDocument(TermsDocument)
    case withdraw
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
}
