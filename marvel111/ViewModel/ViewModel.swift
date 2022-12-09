import Foundation
import RealmSwift

final class ViewModel: NSObject {
    
    private var isFetchingData = false
    
    private let workWithApi = WorkWithApi()
    
    private var offset: Int = 0 {
        willSet { NSLog("\nNew offset = \(newValue)\n") }
    }
    
    let realm = try? Realm()
    
    private lazy var charactersArray: [CharacterModel?] = [] {
        willSet {
            try? realm?.write { realm?.add(newValue.compactMap { $0 }, update: .modified) }
        }
    }
    private lazy var getMoreCharacters: () -> Void = {
        let workItem = DispatchWorkItem { [self] in
            workWithApi.getCharacters(offset: self.offset) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let characterModelArray):
                    if  self.charactersArray.count > 0 {
                        self.charactersArray.remove(at: self.charactersArray.count - 1)
                    }
                    self.charactersArray.append(contentsOf: characterModelArray)
                    self.charactersArray.append(nil)
                    self.offset += characterModelArray.count
                case .failure(let error):
                    self.charactersArray = {
                        guard let charactersResults = self.realm?.objects(CharacterModel.self) else { return [] }
                        return Array(charactersResults)
                    }()
                }
            }
        }
        workItem.notify(queue: .main) { [weak self] in
            self?.isFetchingData = false
        }
        if !self.isFetchingData {
            self.isFetchingData = true
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    func refresh() {
        charactersArray.removeAll(keepingCapacity: true)
        getMoreCharacters()
    }

    
}
