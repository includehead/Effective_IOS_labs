import Foundation
import RealmSwift

enum CollectionCellItem {
    case hero(model: CharacterModel)
    case loading
}

final class MainViewModel: MainViewModelProtocol {
    
    var isLoading = false
    
    @Published private(set) var items: [CollectionCellItem] = []
    
    var itemsPublisher: Published<[CollectionCellItem]>.Publisher { $items }
    
    private let repository = CharacterRepository()
    
    private var offset: Int = 0 {
        willSet { NSLog("\nNew offset = \(newValue)\n") }
    }
    
    let realm = try? Realm()
    
    private func loadMoreCharacters() {
        guard !isLoading else { return }
        isLoading = true
        items.append(.loading)
        repository.getCharacters(offset: self.offset) { [weak self] characterModelArray in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.items.removeAll(where: {
                    switch $0 {
                    case .loading:
                        return true
                    case .hero:
                        return false                        
                    }
                })
                
                let newHeroesArray = characterModelArray.map { CollectionCellItem.hero(model: $0) }
                self.items.append(contentsOf: newHeroesArray)
                self.offset += characterModelArray.count
                self.isLoading = false
            }
        }
    }
    
    func moreDataIsNeeded() {
        loadMoreCharacters()
    }
    
    func refresh() {
        items.removeAll(keepingCapacity: true)
        offset = 0
        loadMoreCharacters()
    }

}
