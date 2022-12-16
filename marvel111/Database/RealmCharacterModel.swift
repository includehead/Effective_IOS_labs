import RealmSwift

final class RealmCharacterModel: Object {
    @Persisted var name: String
    @Persisted var characterDescription: String
    @Persisted(primaryKey: true) var heroId: Int
    @Persisted var imageLink: String
    
    convenience init(id: Int, name: String, imagelink: String, description: String) {
        self.init()
        self.heroId = id
        self.name = name
        self.characterDescription = description
        if imagelink.hasSuffix("jpg") {
            self.imageLink = imagelink
        } else {
            self.imageLink = imagelink + "/portrait_uncanny.jpg"
        }
    }
    
    convenience init(_ characterModel: CharacterModel) {
        self.init()
        self.heroId = characterModel.heroId
        self.name = characterModel.name
        self.characterDescription = characterModel.characterDescription
        self.imageLink = characterModel.imageLink
    }
}
