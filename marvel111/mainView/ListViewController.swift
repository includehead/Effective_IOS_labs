import UIKit
import SnapKit
import Alamofire
import UIImageColors
import Kingfisher
import RealmSwift

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector])
        else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

final class ListViewController: UIViewController {
    
    private var internetConnectionAvailable = true
    
    private var offset: Int = 0
    
    private let background = BackgroundView(frame: .zero)
    private var currentSelectedItemIndex = 0
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private let fullScreenImageViewController = FullScreenImageViewController()
    
    private lazy var mainScrollView: UIScrollView = { [weak self] in
        let mainScrollView = UIScrollView()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data")
        refreshControl.backgroundColor = .systemGray
        refreshControl.addTarget(self, action: #selector(self?.refresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        return mainScrollView
    }()
    
    private let logoImage: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "marvel_logo")
        return logo
    }()

    private let titleTextLabel: UILabel = {
        let titleTextLabel = UILabel()
        titleTextLabel.text = "Choose your hero"
        titleTextLabel.textColor = .white
        titleTextLabel.font = UIFont(name: "Roboto-Black", size: 37)
        titleTextLabel.textAlignment = .center
        return titleTextLabel
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = PagingCollectionViewLayout()
        layout.itemSize = Constants.collectionViewLayoutItemSize
        layout.minimumLineSpacing = Constants.itemSpasing
        layout.scrollDirection = .horizontal
        layout.sectionInset = Constants.collectionViewLayoutInset
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    let realm = try! Realm()
    
    private lazy var charactersArray: [CharacterModel] = [] {
        willSet {
            try! realm.write { realm.add(newValue, update: .modified) }
        }
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var getMoreCharacters: () -> Void = {
        getCharacters(offset: self.offset) { [weak self] result in
            switch result {
            case .success(let characterModelArray):
                self?.charactersArray.append(contentsOf: characterModelArray)
                self?.offset += characterModelArray.count
            case .failure(let error):
                self?.internetConnectionAvailable = false
                self?.charactersArray = {
                    guard let charactersResults = self?.realm.objects(CharacterModel.self) else { return [] }
                    return Array(charactersResults)
                }()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(background)
        mainScrollView.addSubview(logoImage)
        mainScrollView.addSubview(titleTextLabel)
        registerCollectionViewCells()
        mainScrollView.addSubview(collectionView)
        background.setTriangleColor(.black)
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.alwaysBounceHorizontal = false
        mainScrollView.alwaysBounceVertical = true
        setLayout()
    }
    
    @objc func refresh() {
       // Code to refresh collectionView
        offset = 0
        charactersArray.removeAll(keepingCapacity: true)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.mainScrollView.refreshControl?.endRefreshing()
        }
    }

    private func setLayout() {
        
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        background.snp.makeConstraints { make in
            make.edges.equalTo(mainScrollView.snp.edges)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        logoImage.snp.makeConstraints { make in
            make.centerX.equalTo(mainScrollView.snp.centerX)
            make.top.equalTo(mainScrollView).offset(70.0)
            make.size.equalTo(CGSize(width: 140, height: 30))
        }
        titleTextLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(20)
            make.left.equalTo(mainScrollView.snp.left)
            make.right.equalTo(mainScrollView.snp.right)
        }
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(mainScrollView.snp.left)
            make.right.equalTo(mainScrollView.snp.right)
            make.top.equalTo(titleTextLabel.snp.bottom).offset(10)
            make.bottom.equalTo(mainScrollView.snp.bottom).offset(-30)
        }
    }

    private func registerCollectionViewCells() {
        collectionView.register(CollectionViewCell.self,
                                forCellWithReuseIdentifier: String(describing: CollectionViewCell.self))
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if charactersArray.isEmpty { getMoreCharacters() }
        return charactersArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CollectionViewCell.self),
            for: indexPath) as? CollectionViewCell else {
            return .init()
        }
        let tag = indexPath.item + 1
        cell.setup(characterData: charactersArray[indexPath.item], and: tag)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = indexPath.row + 1
        let characterData = charactersArray[indexPath.item]
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
        fullScreenImageViewController.setup(characterData: characterData, tag: tag)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == charactersArray.count - 1 {
            // Last cell is visible
            getMoreCharacters()
            collectionView.reloadData()
            
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: scrollView.frame.size.width / 2 + scrollView.contentOffset.x,
                                  y: scrollView.frame.size.height / 2 + scrollView.contentOffset.y)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            currentSelectedItemIndex = indexPath.row
            let cache = ImageCache.default
            cache.retrieveImage(forKey: "\(charactersArray[indexPath.row].heroId)") { result in
                switch result {
                case .success(let value):
                    self.background.setTriangleColor(value.image?.averageColor ?? .clear)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}
