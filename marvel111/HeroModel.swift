//
//  HeroData.swift
//  marvel111
//
//  Created by Valery Shestakov on 23.10.2022.
//

import UIKit

struct HeroModel {
    let name: String
    let image: UIImage?
    let color: UIColor
    
    init(name: String, image: UIImage?, color: UIColor) {
        self.name = name
        self.image = image
        self.color = color
    }
}
