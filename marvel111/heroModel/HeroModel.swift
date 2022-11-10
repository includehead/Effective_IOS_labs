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

let baseUrl = "https://gateway.marvel.com/v1/public/characters"

class Observer {
    
    @Published var datas = [HeroModel]()
    
    let updateCollectionView: () -> Void
    let showError: (String) -> Void
    
    var offset = 0
    
    private var _totalHeroNumber: Int?
    var totalHeroNumber: Int? {
        get {_totalHeroNumber}
        set {
            if _totalHeroNumber != nil {
                return
            }
            _totalHeroNumber = newValue
        }
    }
    
    init(_ updateCollectionView: @escaping () -> Void, showError: @escaping (String) -> Void) {
        
        self.updateCollectionView = updateCollectionView
        self.showError = showError
        getData()
    }
    
    func getData() {
        AF.request(
            baseUrl,
            method: .get,
            parameters: requestParams(offset: offset),
            encoding: URLEncoding.queryString
        ).responseData { [weak self] in
            guard $0.data != nil else { self?.showError("Unable to fetch data!"); return }
            let responce = try? JSON(data: $0.data!)
            guard let unwrappedResponce = responce else { return }
            let data = unwrappedResponce["data"]
            self?.offset += data["count"].intValue
            let json = data["results"]
            var newHeroes: [HeroModel] = []
            for row in json {
                let id = row.1["id"].stringValue
                let imageURL = row.1["thumbnail"]["path"].stringValue + "." + row.1["thumbnail"]["extension"].stringValue
                guard imageURL != "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg" else { continue }
                let heroData = HeroModel(id: id, updateCollectionView: self!.updateCollectionView)
                NSLog("hero added. id = \(id)┼♡")
                newHeroes.append(heroData)
            }
            self?.datas += newHeroes
            guard (self?.datas.isEmpty) != true else { self?.showError("Got no heroes :-("); return }
            self?.datas[self!.datas.count - 1].getMoreData = self?.getData
        }
    }
}

class HeroModel {
    var name: String?
    private var _imageLink: URL?
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
    private var _getMoreData: (() -> Void)?
    var getMoreData: (() -> Void)? {
        get {_getMoreData}
        set {
            _getMoreData = newValue
        }
    }
    
    init(id: String, updateCollectionView: @escaping () -> Void) {
        self.heroId = id
        self.updateCollectionView = updateCollectionView
        getHeroData()
    }
    
    func getHeroData() {
        AF.request(
            baseUrl + "/" + heroId,
            parameters: requestParams()
        ).responseData { [weak self] in
            debugPrint($0)
            let responce = try? JSON(data: $0.data!)
            guard let unwrappedResponce = responce else { return }
            NSLog("Got response from api: \(unwrappedResponce)😀")
            let data = unwrappedResponce["data"]
            let json = data["results"]
            for row in json {
                self?.name = row.1["name"].stringValue
                let imageURL = row.1["thumbnail"]["path"].stringValue + "/portrait_uncanny." + row.1["thumbnail"]["extension"].stringValue
                self?.imageLink = URL(string: imageURL)
                self?.description = row.1["description"].stringValue
            }
            self?.updateCollectionView()
        }
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
