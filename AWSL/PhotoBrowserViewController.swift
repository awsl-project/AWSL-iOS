//
//  PhotoBrowserViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    
    let photo: Photo
    
    init(_ photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    private let progressView: CircleProgressView = CircleProgressView()
    private let moreButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadImage()
    }
    
    private func loadImage() {
        progressView.isHidden = false
        imageView.kf.setImage(with: photo.info.original.url,
                              options: [.transition(.fade(0.25))],
                              progressBlock: { [weak self] receivedSize, totalSize in
            guard let self = self else { return }
            self.progressView.progress = Float(receivedSize) / Float(totalSize)
        }) { [weak self] result in
            guard let self = self else { return }
            self.progressView.isHidden = true
            switch result {
            case let .success(imageResult):
                self.scrollView.maximumZoomScale = max(1, imageResult.image.size.width / self.view.bounds.width)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func onDoubleTap() {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc private func showMoreMenu() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "保存到相册", style: .default, handler: { action in
            self.savePhoto()
        }))
        sheet.addAction(UIAlertAction(title: "查看原微博", style: .default, handler: { action in
            UIApplication.shared.open(self.photo.weiboUrl)
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(sheet, animated: true)
    }
    
    private func savePhoto() {
        
    }
}

extension PhotoBrowserViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension PhotoBrowserViewController {
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "ellipsis.circle.fill", withConfiguration: config)
        moreButton.setImage(image, for: .normal)
        moreButton.tintColor = .white
        moreButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        moreButton.layer.cornerRadius = 6
        moreButton.clipsToBounds = true
        moreButton.addTarget(self, action: #selector(showMoreMenu), for: .touchUpInside)
        
        view.addSubview(progressView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(moreButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.left.top.size.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        moreButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
    }
}
