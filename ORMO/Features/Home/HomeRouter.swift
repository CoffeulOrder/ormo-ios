import SwiftUI

enum HomeRoute: Hashable {
    case storeSelection
    case storeInfo(Store)
    case search(storeId: String, items: [MenuItem])
    case menuOptions(storeId: String, item: MenuItem)
    case cart
    // attemptId: 같은 결제수단·금액으로 재시도하면 값이 완전히 같아져서, NavigationPath가
    // "이전 시도와 같은 화면"으로 오인해 이미 결과가 나온 화면을 그대로 재사용해버린다
    // (그래서 로딩 화면이 멈춰 보였다). 매 시도마다 새 UUID를 넣어 항상 고유한 값이 되게 한다.
    // 실제 PortOne 결제창(PaymentWebView)을 띄우는 화면. Mock 모드에서는 이 단계를 건너뛰고
    // 바로 paymentProcessing으로 간다.
    case paymentCheckout(attemptId: UUID, checkout: CreatedOrder, paymentMethod: PaymentMethod, totalPrice: Int, storeName: String)
    case paymentProcessing(attemptId: UUID, orderId: Int, paymentId: String, paymentMethod: PaymentMethod, totalPrice: Int, storeName: String)
    // screensToClear: 재시도 시 이 화면까지 포함해 몇 단계를 지워야 장바구니로 돌아가는지.
    // 결제창에서 바로 실패하면 2(checkout+failure), 서버 승인에서 실패하면 3(checkout+processing+failure),
    // Mock 모드는 결제창 단계가 없어 2(processing+failure)다.
    case paymentFailure(attemptId: UUID, orderId: Int, paymentMethod: PaymentMethod, totalPrice: Int, storeName: String, screensToClear: Int)
    case paymentExpired
    case orderComplete(orderId: Int, pickupNumber: Int, storeName: String, queueCount: Int)
    case orderDetail(orderId: Int)
    case orderDetailHistory(Order)
    case receipt(pickupNumber: Int, storeName: String, totalPrice: Int, paidAt: Date)
    case myInfo
    case orderHistory
    case changePassword
    case notificationSettings
    case termsAndPolicy
    case termsDocument(TermsDocument)
    case withdraw
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
}
