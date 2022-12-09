import UIKit
import Alamofire
import CryptoKit
import RealmSwift

final class CharacterModel: Object {
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
}
