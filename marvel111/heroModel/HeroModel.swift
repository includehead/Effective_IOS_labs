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

private let publicKey = "61e5488a7822174f2989d726559fc029"
private let privateKey = "016959c7eec6034a2883f65c348962cd586944ee"

extension String: Error {}

class Observer: ObservableObject {
    
    @Published var datas = [HeroModel]()
    
    let updateCollectionView: () -> Void
    let showError: (String) -> Void
    
    var offset = 0
    
    private var _totalHeroNumber: Int?
    var totalHeroNumber: Int? {
        set {
            if _totalHeroNumber != nil {
                return
            }
        } get {_totalHeroNumber}
    }
    
    init(_ updateCollectionView: @escaping () -> Void, showError: @escaping (String) -> Void) {
        
        self.updateCollectionView = updateCollectionView
        self.showError = showError
        getData()
    }
    
    func getData() {
        let timestamp = NSDate().timeIntervalSince1970
        let dirtyMd5 = Insecure.MD5.hash(data: "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!)
        let md5 = dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
        let request = "https://gateway.marvel.com" + "/v1/public/characters?" + "offset=\(self.offset)" + "&ts=\(timestamp)" + "&apikey=\(publicKey)" + "&hash=\(md5)"
        AF.request(request).responseData { [weak self] in
            guard $0.data != nil else {self!.showError("Unable to fetch data!"); return}
            let responce = try? JSON(data: $0.data!)
            guard let unwrappedResponce = responce else {return}
            let data = unwrappedResponce["data"]
            self!.offset += data["count"].intValue
            let json = data["results"]
            for row in json {
                let id = row.1["id"].stringValue
                let imageURL = row.1["thumbnail"]["path"].stringValue + "." + row.1["thumbnail"]["extension"].stringValue
                guard imageURL != "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg" else {continue}
                let heroData = HeroModel(id: id, updateCollectionView: self!.updateCollectionView)
                NSLog("image URL = \(id)┼♡")
                self?.datas.append(heroData)
            }
            self!.datas[self!.datas.count - 1].getMoreData = self?.getData
            self!.updateCollectionView()
        }
    }
    
//    func getRest() {
//        let timestamp = NSDate().timeIntervalSince1970
//        let dirtyMd5 = Insecure.MD5.hash(data: "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!)
//        let md5 = dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
//
//        var offset = 20
//
//        let request = "https://gateway.marvel.com" + "/v1/public/characters?" + "offset=\(offset)" + "&ts=\(timestamp)" + "&apikey=\(publicKey)" + "&hash=\(md5)"
//        AF.request(request).responseData { [weak self] in
//            let responce = try? JSON(data: $0.data!)
//            guard let unwrappedResponce = responce else {return}
//            NSLog("Got response from api: \(unwrappedResponce)😀")
//            let data = unwrappedResponce["data"]
//            let json = data["results"]
//            for row in json {
//                let id = row.1["id"].stringValue
//                let heroData = HeroModel(id: id)
//                NSLog("Got hero with id = \(id)┼")
//                self?.datas.append(heroData)
//            }
//        }
//    }
    
}

class HeroModel {
    var name: String?
    var _imageLink: URL?
    var color: UIColor?
    var description: String?
    let heroId: String
    let updateCollectionView: () -> Void
    var imageLink: URL? {
        get {
            (getMoreData ?? {})()
            getMoreData = nil
            return _imageLink
        }
        set {
            _imageLink = newValue
        }
    }
    var _getMoreData: (() -> Void)?
    var getMoreData: (() -> Void)? {
        set {
            _getMoreData = newValue
        }
        get {_getMoreData}
    }

//    init(name: String, image: URL?, color: UIColor, description: String) {
//        self.name = name
//        self.imageLink = image
//        self.color = color
//        self.description = description
//        self.heroId = ""
//    }
    
    init(id: String, updateCollectionView: @escaping () -> Void) {
        self.heroId = id
        self.updateCollectionView = updateCollectionView
        getHeroData()
    }
    
    func getHeroData() {
        let timestamp = NSDate().timeIntervalSince1970
        let dirtyMd5 = Insecure.MD5.hash(data: "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!)
        let md5 = dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
        
        let request = "https://gateway.marvel.com" + "/v1/public/characters/\(heroId)?" + "ts=\(timestamp)" + "&apikey=\(publicKey)" + "&hash=\(md5)"
        AF.request(request).responseData { [unowned self] in
            debugPrint($0)
            let responce = try? JSON(data: $0.data!)
            guard let unwrappedResponce = responce else {return}
            NSLog("Got response from api: \(unwrappedResponce)😀")
            let data = unwrappedResponce["data"]
            let json = data["results"]
            for row in json {
                name = row.1["name"].stringValue
                let imageURL = row.1["thumbnail"]["path"].stringValue + "/portrait_uncanny." + row.1["thumbnail"]["extension"].stringValue
                imageLink = URL(string: imageURL)
                description = row.1["description"].stringValue
            }
            updateCollectionView()
        }
    }
    
}
