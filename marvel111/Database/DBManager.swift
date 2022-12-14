import RealmSwift
import Foundation

final class DBManager {
    
    let realm: Realm?
    
    init() {
        self.realm = try? Realm()
    }
    
    func write(object: Object) {
        
    }
    
    func get<T: Object> (id: Int) -> T? {
        return nil
    }
    
    func getAll<T: Object> () -> [T]? {
        return nil
    }
}

extension DBManager: CharacterModelDatabaseProtocol {
    func getCharacter(id: Int) -> CharacterModel? {
        guard let model = realm?.object(ofType: RealmCharacterModel.self, forPrimaryKey: id) else { return nil }
        return CharacterModel(realmModel: model)
    }
    
    func write(character: CharacterModel) {
        try? realm?.write { realm?.add(RealmCharacterModel(character), update: .modified) }
    }
    
    func writeAll(characters: [CharacterModel]) {
        let modelsArray = characters.map { RealmCharacterModel($0) }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            try? self.realm?.write { self.realm?.add(modelsArray, update: .modified) }
        }
    }
    
    func getAll() -> [CharacterModel] {
        guard let charactersResults = self.realm?.objects(RealmCharacterModel.self) else { return [] }
        return charactersResults.compactMap { CharacterModel(realmModel: $0) }
    }
}

extension CharacterModel {
    convenience init? (realmModel: RealmCharacterModel) {
        self.init(id: realmModel.heroId, name: realmModel.name, imagelink: realmModel.imageLink, description: realmModel.characterDescription)
    }
}
