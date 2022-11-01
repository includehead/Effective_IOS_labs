import UIKit
import TinyConstraints
import Kingfisher

class FullScreenImageViewController: UIViewController {
    
    private let textOffset = 30
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
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
        heroDescriptionTextLabel.text = """
            Marvel Entertainment, LLC is an American entertainment company founded in June 1998 and based in New York City
            """
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Force any ongoing scrolling to stop and prevent the image view jumping during dismiss animation.
        // Which is caused by the scroll animation and dismiss animation running at the same time.
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(heroImageView)
        wrapperView.addSubview(heroDescriptionTextLabel)
        wrapperView.addSubview(heroNameTextLabel)
        
        scrollView.edgesToSuperview()
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        heroImageView.centerInSuperview()
        heroImageView.edges(to: scrollView.contentLayoutGuide)
        
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
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
//        scrollView.maximumZoomScale = 2.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
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
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        heroImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        heroImageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                          y: currentContentSize.height * 0.5 + offsetY)
    }
}
