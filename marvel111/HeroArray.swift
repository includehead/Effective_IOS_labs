//
//  HeroArray.swift
//  marvel111
//
//  Created by Valery Shestakov on 23.10.2022.
//

import UIKit

struct HeroArray {
    private let heroArray = [
        HeroModel(name: "Deadpool", image: UIImage(named: "deadpool"), color: .green),
        HeroModel(name: "Iron Man", image: UIImage(named: "iron_man"), color: .red),
        HeroModel(name: "Captain America", image: UIImage(named: "captain"), color: .black),
        HeroModel(name: "Spider Man", image: UIImage(named: "spider_man"), color: .purple),
        HeroModel(name: "Doctor Strange", image: UIImage(named: "strange"), color: .blue),
        HeroModel(name: "Thor", image: UIImage(named: "thor"), color: .brown),
        HeroModel(name: "Thanos", image: UIImage(named: "thanos"), color: .cyan),
    ]
    func get(_ index: Int) -> HeroModel {
        return heroArray[index]
    }
    func count() -> Int {
        return heroArray.count
    }
}
