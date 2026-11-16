import Foundation

@Observable
final class SignUpCompletionViewModel {
    let name: String

    init(name: String) {
        self.name = name
    }
}
