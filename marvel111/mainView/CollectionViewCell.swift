import UIKit
import Kingfisher

final class CollectionViewCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
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

    func setup(heroData: HeroModel, and tag: Int) {
        imageView.image = .init()
        imageView.layoutIfNeeded()
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        let resource = ImageResource(downloadURL: (heroData.imageLink ?? URL.init(string: "http://127.0.0.1"))!, cacheKey: heroData.heroId)
        imageView.kf.setImage(
            with: resource,
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]
        ) {
            switch $0 {
            case .success(let value):
                NSLog("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                NSLog("Job failed: \(error.localizedDescription)")
            }
        }
        imageView.tag = tag
        textLabel.text = heroData.name
    }

    private func setUpLayout() {
        addSubview(imageView)
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.left.equalTo(self.snp.left).offset(20)
            $0.right.equalTo(self.snp.right).offset(-10)
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
