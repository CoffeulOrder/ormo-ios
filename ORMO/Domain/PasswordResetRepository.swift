import Foundation

// 비밀번호를 잊어버려 이메일 인증으로 재설정하는 플로우. 서버가 "새 비밀번호가 기존과 같은지"를
// 검증해주는 수단이 없어(비교 대상인 현재 비밀번호를 클라이언트도 서버도 평문으로 들고 있지 않음),
// 형식 검사(8자 이상·영문+숫자) 외에는 제출 시점에 한 번만 호출한다.
protocol PasswordResetRepository {
    func resetPassword(verificationToken: String, newPassword: String) async throws
}
