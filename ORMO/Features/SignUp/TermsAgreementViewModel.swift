import Foundation

struct AgreementItem: Identifiable {
    let id = UUID()
    let title: String
    var isAgreed: Bool
}

@Observable
final class TermsAgreementViewModel {
    var items: [AgreementItem] = [
        AgreementItem(title: "[필수] 서비스 이용약관", isAgreed: false),
        AgreementItem(title: "[필수] 서비스 이용약관", isAgreed: false)
    ]

    var isAllAgreed: Bool { items.allSatisfy(\.isAgreed) }
    var canSubmit: Bool { items.allSatisfy(\.isAgreed) }

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
        // TODO: 0.2.6 가입 완료 · 축하 모션으로 이동
    }
}
