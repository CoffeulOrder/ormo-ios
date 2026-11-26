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
        let useMock = AppConfig.useMock

        // Phase 1: 인증·회원 5종은 실서버 연동 완료.
        authRepository = useMock ? MockAuthRepository() : RemoteAuthRepository()
        signUpRepository = useMock ? MockSignUpRepository() : RemoteSignUpRepository()
        verificationCodeRepository = useMock ? MockVerificationCodeRepository() : RemoteVerificationCodeRepository()
        passwordResetRepository = useMock ? MockPasswordResetRepository() : RemotePasswordResetRepository()
        userProfileRepository = useMock ? MockUserProfileRepository() : RemoteUserProfileRepository()
        // 백엔드에 대응 API가 없어(명세서 43개 중 없음) 당분간 Mock 고정.
        schoolEmailDomainRepository = MockSchoolEmailDomainRepository()

        // Phase 2: 매장·메뉴 실서버 연동 완료.
        cafeRepository = useMock ? MockCafeRepository() : RemoteCafeRepository()
        menuRepository = useMock ? MockMenuRepository() : RemoteMenuRepository()

        orderRepository = MockOrderRepository()
        orderHistoryRepository = MockOrderHistoryRepository()
        liveOrderRepository = MockLiveOrderRepository()

        paymentRepository = MockPaymentRepository()
    }
}
