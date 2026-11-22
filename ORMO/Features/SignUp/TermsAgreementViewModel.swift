import Foundation

struct AgreementItem: Identifiable {
    let id = UUID()
    let document: TermsDocument
    var isAgreed: Bool

    var title: String { "[필수] \(document.title)" }
}

@Observable
final class TermsAgreementViewModel {
    var items: [AgreementItem] = [
        AgreementItem(document: .serviceTerms, isAgreed: false),
        AgreementItem(document: .privacyPolicy, isAgreed: false)
    ]

    var isAllAgreed: Bool { items.allSatisfy(\.isAgreed) }
    var canSubmit: Bool { items.allSatisfy(\.isAgreed) }
    var isCompleted = false

    func toggleAll() {
        let newValue = !isAllAgreed
        for index in items.indices {
            items[index].isAgreed = newValue
        }
    }

    func toggle(_ item: AgreementItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isAgreed.toggle()
    }

    func submitTapped() {
        guard canSubmit else { return }
        isCompleted = true
    }
}
