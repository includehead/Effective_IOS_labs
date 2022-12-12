import RealmSwift

final class DBManager {
    
    let realm: Realm?
    
    init() {
        realm = try? Realm()
    }
    
    func write(object: Object) {
        
    }
    
    func getCharacter<T: Object> (id: Int) -> T? {
        return nil
    }
    
    func getAll<T: Object> () -> [T]? {
        return nil
    }
}

extension DBManager: DatabaseProtocol {
    func getCharacter(id: Int) -> CharacterModel? {
        guard let model = realm?.object(ofType: RealmCharacterModel.self, forPrimaryKey: id) else { return nil }
        return CharacterModel(realmModel: model)
    }
    
    func write(character: CharacterModel) {
        try? realm?.write { realm?.add(RealmCharacterModel(character), update: .modified) }
    }
    
    func writeAll(characters: [CharacterModel]) {
        let modelsArray = characters.map { RealmCharacterModel($0) }
        try? realm?.write { realm?.add(modelsArray, update: .modified) }
    }
    
    func getAll() -> [CharacterModel]? {
        guard let charactersResults = self.realm?.objects(RealmCharacterModel.self) else { return [] }
        return charactersResults.compactMap { CharacterModel(realmModel: $0) }
    }
}

extension CharacterModel {
    convenience init? (realmModel: RealmCharacterModel) {
        self.init(id: realmModel.heroId, name: realmModel.name, imagelink: realmModel.imageLink, description: realmModel.characterDescription)
    }
}
