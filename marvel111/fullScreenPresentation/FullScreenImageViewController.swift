import UIKit
import TinyConstraints
import Kingfisher

class FullScreenImageViewController: UIViewController {
    
    private let textOffset = 30
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let heroNameTextLabel: UILabel = {
        let heroNameTextLabel = UILabel()
        heroNameTextLabel.textColor = .white
        heroNameTextLabel.font = UIFont(name: "Roboto-Black", size: 37)
        heroNameTextLabel.shadowColor = .black
        heroNameTextLabel.shadowOffset = CGSize(width: 5, height: 5)
        return heroNameTextLabel
    }()
    
    private let heroDescriptionTextLabel: UILabel = {
        let heroDescriptionTextLabel = UILabel()
        heroDescriptionTextLabel.textColor = .white
        heroDescriptionTextLabel.font = UIFont(name: "Roboto-Black", size: 34)
        heroDescriptionTextLabel.lineBreakMode = .byWordWrapping
        heroDescriptionTextLabel.numberOfLines = 0
        heroDescriptionTextLabel.shadowColor = .black
        heroDescriptionTextLabel.shadowOffset = CGSize(width: 5, height: 5)
        return heroDescriptionTextLabel
    }()
    
    private lazy var imageViewLandscapeConstraint = heroImageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = heroImageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    func setup(heroData: HeroModel, tag: Int) {
        heroImageView.image = .init()
        wrapperView.tag = tag
        heroImageView.kf.setImage(with: heroData.imageLink ?? URL(string: ""))
        heroNameTextLabel.text = heroData.name
        heroDescriptionTextLabel.text = heroData.description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(wrapperView)
        wrapperView.addSubview(heroImageView)
        wrapperView.addSubview(heroDescriptionTextLabel)
        wrapperView.addSubview(heroNameTextLabel)
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: view)
        wrapperView.width(to: view)
        wrapperView.height(to: view)
        
        heroImageView.centerInSuperview()
        heroImageView.edges(to: wrapperView)
        
        heroDescriptionTextLabel.snp.makeConstraints {
            $0.left.equalTo(wrapperView.snp.left).offset(textOffset)
            $0.right.equalTo(wrapperView.snp.right).offset(-textOffset)
            $0.bottom.equalTo(wrapperView.snp.bottom).offset(-textOffset)
        }
        heroNameTextLabel.snp.makeConstraints {
            $0.left.equalTo(wrapperView.snp.left).offset(textOffset)
            $0.right.equalTo(wrapperView.snp.right)
            $0.bottom.equalTo(heroDescriptionTextLabel.snp.top).offset(-10)
        }
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
}
