//
//  HeroData.swift
//  marvel111
//
//  Created by Valery Shestakov on 23.10.2022.
//

import UIKit

struct HeroModel {
    let name: String
    let imageLink: URL?
    let color: UIColor

    init(name: String, image: URL?, color: UIColor) {
        self.name = name
        self.imageLink = image
        self.color = color
    }
}
