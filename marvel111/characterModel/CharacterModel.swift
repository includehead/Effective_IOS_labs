import UIKit
import SwiftyJSON
import Alamofire
import CryptoKit
import RealmSwift

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

let baseUrl = "https://gateway.marvel.com/v1/public/characters"

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

func getCharacters(offset: Int = 0, _ completion: @escaping (Result<[CharacterModel], Error>) -> Void) {
    AF.request(
        baseUrl,
        parameters: requestParams(offset: offset)
    ).responseDecodable(of: CharactersPayload.self) { response in
        switch response.result {
        case .success(let charactersPayload):
            let charactersDecodable = charactersPayload.data?.results
            var characterModelArray: [CharacterModel] = []
            for character in charactersDecodable ?? [] {
                let newModel = CharacterModel(id: character?.id ?? -1, name: character?.name ?? "",
                                              imagelink: character?.thumbnail?.imageUrlString ?? "",
                                              description: character?.description ?? "")
                characterModelArray.append(newModel)
            }
            completion(.success(characterModelArray))
        case .failure(let failure):
            NSLog(failure.localizedDescription)
            completion(.failure("Probably network error."))
        }
    }
}

func getCharacter(id: Int, _ completion: @escaping (Result<CharacterModel, Error>) -> Void) {
    AF.request(
        baseUrl + "/\(id)",
        parameters: requestParams()
    ).responseDecodable(of: CharactersPayload.self) { response in
        switch response.result {
        case .success(let charactersPayload):
            let charactersDecodable = charactersPayload.data?.results
            var characterModelArray: [CharacterModel] = []
            for character in charactersDecodable ?? [] {
                let newModel = CharacterModel(id: character?.id ?? -1, name: character?.name ?? "",
                                              imagelink: character?.thumbnail?.imageUrlString ?? "",
                                              description: character?.description ?? "")
                characterModelArray.append(newModel)
            }
            completion(.success(characterModelArray.first ?? .init()))
        case .failure(let failure):
            NSLog(failure.localizedDescription)
            completion(.failure("Definetely network error."))
        }
    }
}

struct CharactersPayload: Decodable {
    let data: CharacterListDecodable?
}

struct CharacterListDecodable: Decodable {
    let count: Int?
    let results: [CharacterDecodable?]?
}

struct CharacterDecodable: Decodable {
    let name: String?
    let id: Int?
    let thumbnail: Thumbnail?
    let description: String?
}

struct Thumbnail: Decodable {
    let imageUrlString: String?
    let imageExtension: String?
    enum CodingKeys: String, CodingKey {
        case imageUrlString = "path"
        case imageExtension = "extension"
    }
}

func requestParams(offset: Int = 0) -> [String: String] {
    let privateKey = "016959c7eec6034a2883f65c348962cd586944ee"
    let apikey = "61e5488a7822174f2989d726559fc029"
    let timeStamp = NSDate().timeIntervalSince1970
    let hash = getHash(timeStamp: timeStamp, apikey: apikey, privateKey: privateKey)
    return ["apikey": apikey, "ts": "\(timeStamp)", "hash": hash, "offset": "\(offset)"]
}

private func getHash(timeStamp: Double, apikey: String, privateKey: String) -> String {
    let dirtyMd5 = Insecure.MD5.hash(data: "\(timeStamp)\(privateKey)\(apikey)".data(using: .utf8)!)
    return dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
}
