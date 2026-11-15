import Foundation

protocol VerificationCodeRepository {
    func verify(code: String) async -> Bool
}
