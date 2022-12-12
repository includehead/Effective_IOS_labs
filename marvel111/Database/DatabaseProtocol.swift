import RealmSwift

protocol DatabaseProtocol: AnyObject {
    
    func write(character: CharacterModel)
    func writeAll(characters: [CharacterModel])
    func getCharacter(id: Int) -> CharacterModel?
    func getAll() -> [CharacterModel]?
    
}
