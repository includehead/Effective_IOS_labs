import Foundation

final class FullScreenImageViewModel {
    
    private let repository = CharacterRepository()
    
    func getCharacter(id: Int, completion: @escaping (CharacterModel?) -> Void) {
        repository.getCharacter(id: id) { result in
            switch result {
            case .success(let character):
                completion(character)
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
    
}
