//
//  CollectionViewCell.swift
//  marvel111
//
//  Created by Valery Shestakov on 21.10.2022.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15.0
        imageView.clipsToBounds = true
        return imageView
    }()
    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont(name: "Roboto-Black", size: 24)
        textLabel.textColor = .white
        textLabel.shadowColor = .black
        textLabel.shadowOffset = CGSize(width: 5, height: 5)
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    func setup(heroData: HeroModel) {
        imageView.image = heroData.image ?? .init()
        textLabel.text = heroData.name
    }
    
    private func setUpLayout() {
        addSubview(imageView)
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.left.equalTo(self.snp.left).offset(20)
            $0.top.equalTo(self.snp.bottom).offset(-50)
        }
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
