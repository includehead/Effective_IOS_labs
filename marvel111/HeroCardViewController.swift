//
//  HeroCardViewController.swift
//  marvel111
//
//  Created by Valery Shestakov on 27.10.2022.
//

import UIKit

class HeroCardViewController: UIViewController {
    
    private let textOffset = 30
    private let heroImage = UIImageView()

    private let heroNameTextLabel: UILabel = {
        let heroNameTextLabel = UILabel()        
        heroNameTextLabel.textColor = .white
        heroNameTextLabel.font = UIFont(name: "Roboto-Black", size: 37)
        return heroNameTextLabel
    }()
    private let heroDescriptionTextLabel: UILabel = {
        let heroDescriptionTextLabel = UILabel()
        heroDescriptionTextLabel.textColor = .white
        heroDescriptionTextLabel.font = UIFont(name: "Roboto-Black", size: 34)
        heroDescriptionTextLabel.lineBreakMode = .byWordWrapping
        heroDescriptionTextLabel.numberOfLines = 0
        return heroDescriptionTextLabel
    }()
    private var didSetupCpnstraints = false

    private func setupConstraints() {
        heroImage.snp.makeConstraints {
            $0.edges.equalTo(view.snp.edges)
        }
        heroDescriptionTextLabel.snp.makeConstraints {
            $0.left.equalTo(view.snp.left).offset(textOffset)
            $0.right.equalTo(view.snp.right).offset(-textOffset)
            $0.bottom.equalTo(view.snp.bottom).offset(-textOffset)
        }
        heroNameTextLabel.snp.makeConstraints {
            $0.left.equalTo(view.snp.left).offset(textOffset)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(heroDescriptionTextLabel.snp.top).offset(-10)
        }
    }
    
    func setup(image: UIImage?, name: String, description: String) {
        heroImage.image = image ?? .init()
        heroNameTextLabel.text = name
        heroDescriptionTextLabel.text = description
        setupConstraints()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(heroImage)
        view.addSubview(heroDescriptionTextLabel)
        view.addSubview(heroNameTextLabel)
    }
}
