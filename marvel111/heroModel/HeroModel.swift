//
//  HeroData.swift
//  marvel111
//
//  Created by Valery Shestakov on 23.10.2022.
//

import UIKit
import SwiftyJSON
import Alamofire
import CryptoKit

class Observer: ObservableObject {
    
    @Published var datas = [HeroModel]()
    
    private let publicKey = "61e5488a7822174f2989d726559fc029"
    let privateKey = "016959c7eec6034a2883f65c348962cd586944ee"

    init() {
        
        let timestamp = NSDate().timeIntervalSince1970
        let dirtyMd5 = Insecure.MD5.hash(data: "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!)
        let md5 = dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
        AF.request("https://gateway.marvel.com" + "/v1/public/characters?" + "offset=20" + "&ts=\(timestamp)" + "&apikey=\(publicKey)" + "&hash=\(md5)").responseData {
            let responce = try? JSON(data: $0.data!)
            guard let unwrappedResponce = responce else {return}
            NSLog("Got response from api: \(unwrappedResponce)😀")
            let data = unwrappedResponce["data"]
            let json = data["results"]
            for row in json {
                let imageURL = row.1["thumbnail"]["path"].stringValue + row.1["thumbnail"]["extention"].stringValue
                let description = row.1["description"].stringValue
                let heroData = HeroModel(name: row.1["name"].stringValue, image: URL(string: imageURL), color: .white, description: description)
            }
        }
    }
}

struct HeroModel {
    let name: String
    let imageLink: URL?
    let color: UIColor
    let description: String

    init(name: String, image: URL?, color: UIColor, description: String) {
        self.name = name
        self.imageLink = image
        self.color = color
        self.description = description
    }
}
