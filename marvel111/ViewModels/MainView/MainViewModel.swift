import Foundation
import RealmSwift

enum CollectionCellItem {
    case hero(model: CharacterModel)
    case loading
}

final class MainViewModel {
    
    var database: DatabaseProtocol = DBManager()
    
    var isFetchingData = false
    
    @Published private(set) var items: [CollectionCellItem] = []
    
    private let repository = Repository()
    
    private var offset: Int = 0 {
        willSet { NSLog("\nNew offset = \(newValue)\n") }
    }
    
    let realm = try? Realm()
    
    func loadMoreCharacters() {
        let workItem = DispatchWorkItem { [self] in
            repository.getCharacters(offset: self.offset) { [weak self] result in
                self?.items.removeLast()
                guard let self = self else { return }
                switch result {
                case .success(let characterModelArray):
                    guard let characterModelArrayUnwrapped = characterModelArray else { return }
                    let newHeroesArray = characterModelArrayUnwrapped.map { CollectionCellItem.hero(model: $0)}
                    self.items.append(contentsOf: newHeroesArray)
                    self.database.writeAll(characters: characterModelArrayUnwrapped)
                    self.offset += characterModelArrayUnwrapped.count
                case .failure(_:):
                    self.items = {
                        guard let charactersResults = self.database.getAll() else { return [] }
                        return Array(charactersResults.map { .hero(model: $0) })
                    }()
                }
                self.isFetchingData = false
            }
        }
        if !self.isFetchingData {
            self.isFetchingData = true
            items.append(.loading)
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    func refresh() {
        items.removeAll(keepingCapacity: true)
        offset = 0
        loadMoreCharacters()
    }

}
