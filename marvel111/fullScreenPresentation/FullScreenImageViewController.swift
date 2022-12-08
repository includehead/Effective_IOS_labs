import UIKit
import SnapKit

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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    func setup(characterData: CharacterModel?, tag: Int) {
        heroImageView.image = .init()
        wrapperView.tag = tag
        guard let data = characterData else { return }
        getCharacter(id: data.heroId) { [weak self] result in
            switch result {
            case .success(let characterModel):
                self?.heroImageView.kf.setImage(with: URL(string: characterModel.imageLink) ?? URL(string: "http://127.0.0.1"))
                self?.heroNameTextLabel.text = characterModel.name
                self?.heroDescriptionTextLabel.text = characterModel.characterDescription
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(wrapperView)
        wrapperView.addSubview(heroImageView)
        wrapperView.addSubview(heroDescriptionTextLabel)
        wrapperView.addSubview(heroNameTextLabel)
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        heroImageView.snp.makeConstraints { make in
            make.edges.equalTo(wrapperView)
        }
        
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
}
