import Foundation

@Observable
final class StoreSelectionViewModel {
    var campusName: String = ""
    var stores: [Store] = []
    var isLoadFailed = false
    var storeForChangeConfirmation: Store?

    private let cafeRepository: CafeRepository

    init(cafeRepository: CafeRepository = AppContainer.shared.cafeRepository) {
        self.cafeRepository = cafeRepository
    }

    func load() async {
        isLoadFailed = false
        do {
            async let campus = cafeRepository.fetchCampusName()
            async let storeList = cafeRepository.fetchStores()
            campusName = try await campus
            stores = try await storeList
        } catch {
            isLoadFailed = true
        }
    }

    func storeTapped(_ store: Store) {
        storeForChangeConfirmation = store
    }
}
