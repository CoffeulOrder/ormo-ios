import SwiftUI
import PortOneSdk

// 실제 PortOne 결제창. CartViewModel이 만든 주문(PENDING_PAYMENT)의 결제 정보를 그대로
// PaymentWebView에 넘겨 보여주고, 결과에 따라 결제 확인 화면(성공) 또는 실패 화면으로 보낸다.
// Mock 모드에서는 이 화면 자체를 쓰지 않는다(CartView가 바로 paymentProcessing으로 보낸다).
struct PaymentCheckoutView: View {
    @Environment(HomeRouter.self) private var router
    let checkout: CreatedOrder
    let paymentMethod: PaymentMethod
    let totalPrice: Int
    let storeName: String
    private let userProfileRepository: UserProfileRepository = AppContainer.shared.userProfileRepository

    // 이니시스 V2 일반 결제 등 일부 PG는 구매자 이름이 필수라, 결제창을 열기 전에 먼저 받아온다.
    @State private var customerProfile: UserProfile?
    @State private var hasLoadedProfile = false

    var body: some View {
        Group {
            if hasLoadedProfile {
                if let webView = PaymentWebView(request: request, onCompletion: handleResult) {
                    webView
                } else {
                    // 요청 자체를 못 만든 경우(이론상 거의 없음, JSON 인코딩 실패 등) 실패 화면으로.
                    Color.clear.onAppear(perform: navigateToFailure)
                }
            } else {
                Color.clear
            }
        }
        .task {
            customerProfile = try? await userProfileRepository.fetchProfile()
            hasLoadedProfile = true
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var request: PaymentRequest {
        let payMethod: PaymentPayMethod
        var easyPay: PaymentRequestUnionEasyPay?
        switch paymentMethod {
        case .card:
            payMethod = .CARD
        case .tossPay:
            payMethod = .EASY_PAY
            easyPay = PaymentRequestUnionEasyPay(easyPayProvider: .TOSSPAY)
        case .naverPay:
            payMethod = .EASY_PAY
            easyPay = PaymentRequestUnionEasyPay(easyPayProvider: .NAVERPAY)
        case .kakaoPay:
            payMethod = .EASY_PAY
            easyPay = PaymentRequestUnionEasyPay(easyPayProvider: .KAKAOPAY)
        }

        return PaymentRequest(
            storeId: checkout.portOneStoreId,
            paymentId: checkout.paymentId,
            orderName: checkout.orderName,
            totalAmount: checkout.amount,
            currency: Currency(rawValue: checkout.currency) ?? .KRW,
            payMethod: payMethod,
            channelKey: checkout.channelKey,
            customer: Customer(fullName: customerProfile?.name ?? "고객", email: customerProfile?.email),
            appScheme: AppConfig.portOneAppScheme,
            easyPay: easyPay
        )
    }

    private func handleResult(_ result: PaymentResult) {
        DispatchQueue.main.async {
            switch result {
            case .success(let payment):
                router.path.removeLast()
                router.path.append(
                    HomeRoute.paymentProcessing(
                        attemptId: UUID(),
                        orderId: checkout.orderId,
                        paymentId: payment.paymentId,
                        paymentMethod: paymentMethod,
                        totalPrice: totalPrice,
                        storeName: storeName
                    )
                )
            case .failure:
                navigateToFailure()
            }
        }
    }

    private func navigateToFailure() {
        router.path.removeLast()
        router.path.append(
            HomeRoute.paymentFailure(
                attemptId: UUID(),
                orderId: checkout.orderId,
                paymentMethod: paymentMethod,
                totalPrice: totalPrice,
                storeName: storeName,
                screensToClear: 2
            )
        )
    }
}
