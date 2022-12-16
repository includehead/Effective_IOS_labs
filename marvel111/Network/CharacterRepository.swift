import Alamofire
import CryptoKit
import Foundation

class CharacterRepository {
    
    private var database: CharacterModelDatabaseProtocol = DBManager()
    
    private var isThereInternetConnection = true
    
    private let baseUrl = "https://gateway.marvel.com/v1/public/characters"
    
    func getCharacters(offset: Int = 0, _ completion: @escaping ([CharacterModel]) -> Void) {
        guard isThereInternetConnection == true else { completion(self.database.getAll()); return }
        AF.request(
            baseUrl,
            parameters: requestParams(offset: offset)
        ).responseDataDecodable(of: CharacterListPayload.self) { response in
            switch response.result {
            case .success(let charactersPayload):
                debugPrint(response)
                guard let charactersDecodable = charactersPayload.data?.results else { completion(self.database.getAll()); return }
                let characterModelArray: [CharacterModel] = charactersDecodable.compactMap { self.createCharacterFromDecodable(character: $0) }
                self.database.writeAll(characters: characterModelArray)
                completion(characterModelArray)
            case .failure(let failure):
                self.isThereInternetConnection = false
                NSLog(failure.localizedDescription)
                completion(self.database.getAll())
            }
        }
    }

    func getCharacter(id: Int, _ completion: @escaping (CharacterModel?) -> Void) {
        AF.request(
            baseUrl + "/\(id)",
            parameters: requestParams()
        ).responseDataDecodable(of: CharacterListPayload.self) { response in
            switch response.result {
            case .success(let charactersPayload):
                guard let charactersDecodable = charactersPayload.data?.results else { completion(nil); return }
                let characterModelArray: [CharacterModel] = charactersDecodable.compactMap { self.createCharacterFromDecodable(character: $0) }
                completion(characterModelArray.first)
            case .failure(let failure):
                NSLog(failure.localizedDescription)
                completion(nil)
            }
        }
    }
    
    private func createCharacterFromDecodable(character: CharacterPayload?) -> CharacterModel? {
        guard let unwrappedCharacterPayload = character else { return nil }
        guard let id = unwrappedCharacterPayload.id else { return nil }
        
        return CharacterModel(id: id, name: unwrappedCharacterPayload.name,
                              imagelink: unwrappedCharacterPayload.thumbnail?.imageUrlString,
                              description: character?.description)
    }

    private func requestParams(offset: Int = 0) -> [String: String] {
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

    private struct CharacterListPayload: Decodable {
        let count: Int?
        let results: [CharacterPayload?]?
    }

    private struct CharacterPayload: Decodable {
        let name: String?
        let id: Int?
        let thumbnail: ThumbnailPayload?
        let description: String?
    }

    private struct ThumbnailPayload: Decodable {
        let imageUrlString: String?
        let imageExtension: String?
        
        enum CodingKeys: String, CodingKey {
            case imageUrlString = "path"
            case imageExtension = "extension"
        }
    }
}
