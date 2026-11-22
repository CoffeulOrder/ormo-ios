import Foundation

@Observable
final class MenuSearchViewModel {
    private static let maxRecentSearches = 3

    var query: String = ""
    var recentSearches: [String] = []

    private let allItems: [MenuItem]

    init(allItems: [MenuItem]) {
        self.allItems = allItems
    }

    var results: [MenuItem] {
        guard !query.isEmpty else { return [] }
        return allItems.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var popularItems: [MenuItem] {
        Array(allItems.filter { $0.badge == .popular }.prefix(3))
    }

    func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0 == trimmed }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > Self.maxRecentSearches {
            recentSearches.removeLast()
        }
    }

    func recentSearchTapped(_ term: String) {
        query = term
    }

    func removeRecentSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
    }

    func resultTapped(_ item: MenuItem) {
        submitSearch()
        // TODO: 2.2.1 옵션 선택 화면으로 이동
    }
}
