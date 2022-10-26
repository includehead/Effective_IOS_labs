import UIKit
import SnapKit

final class ListViewController: UIViewController {
    
    let heroArray = HeroArray()
    
    let background = BackgroundView(frame: .zero)
    
    let marvelLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "marvel_logo")
        return logo
    }()

    let chooseYourHeroText: UILabel = {
        let text = UILabel()
        text.text = "Choose your hero"
        text.textColor = .white
        text.font = UIFont(name: "Roboto-Black", size: 37)
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()

    lazy var collectionView: UICollectionView = {
        let layout = PagingCollectionViewLayout()
        layout.itemSize = Constants.collectionViewLayoutItemSize
        layout.minimumLineSpacing = Constants.itemSpasing
        layout.scrollDirection = .horizontal
        layout.sectionInset = Constants.collectionViewLayoutInset
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(background)
        view.addSubview(marvelLogo)
        view.addSubview(chooseYourHeroText)
        registerCollectionViewCells()
        view.addSubview(collectionView)
        background.setTriangleColor(heroArray.get(0).color)
        setLayout()
    }

    private func setLayout() {
        background.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }
        marvelLogo.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view).offset(70.0)
            make.size.equalTo(CGSize(width: 140, height: 30))
        }
        
        chooseYourHeroText.snp.makeConstraints { make in
            make.centerX.equalTo(marvelLogo)
            make.top.equalTo(marvelLogo.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 300, height: 60))
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(chooseYourHeroText.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }

    private func registerCollectionViewCells() {
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CollectionViewCell.self))
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroArray.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as? CollectionViewCell else {
            return .init()
        }
        cell.setup(heroData: heroArray.get(indexPath.item))
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: scrollView.frame.size.width / 2 + scrollView.contentOffset.x,
                                  y: scrollView.frame.size.height / 2 + scrollView.contentOffset.y)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            background.setTriangleColor(heroArray.get(indexPath.row).color)
        }
    }
}
