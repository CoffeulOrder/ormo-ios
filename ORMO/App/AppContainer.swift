import Foundation

// 화면들이 Mock*Repository()를 직접 생성하던 자리를 대신하는 단일 조립 지점.
// Phase 0에서는 구조만 만들고 전부 Mock을 그대로 돌려준다(동작 변화 없음). 이후 백엔드 연동
// Phase가 하나씩 끝날 때마다, 해당 Repository만 Remote 구현으로 바꿔 끼운다.
final class AppContainer {
    static let shared = AppContainer()

    let authRepository: AuthRepository
    let signUpRepository: SignUpRepository
    let verificationCodeRepository: VerificationCodeRepository
    let passwordResetRepository: PasswordResetRepository
    let userProfileRepository: UserProfileRepository
    let schoolEmailDomainRepository: SchoolEmailDomainRepository

    let cafeRepository: CafeRepository
    let menuRepository: MenuRepository

    let orderRepository: OrderRepository
    let orderHistoryRepository: OrderHistoryRepository
    let liveOrderRepository: LiveOrderRepository

    let paymentRepository: PaymentRepository

    private init() {
        authRepository = MockAuthRepository()
        signUpRepository = MockSignUpRepository()
        verificationCodeRepository = MockVerificationCodeRepository()
        passwordResetRepository = MockPasswordResetRepository()
        userProfileRepository = MockUserProfileRepository()
        schoolEmailDomainRepository = MockSchoolEmailDomainRepository()

        cafeRepository = MockCafeRepository()
        menuRepository = MockMenuRepository()

        orderRepository = MockOrderRepository()
        orderHistoryRepository = MockOrderHistoryRepository()
        liveOrderRepository = MockLiveOrderRepository()

        paymentRepository = MockPaymentRepository()
    }
}
