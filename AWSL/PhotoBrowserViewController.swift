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
        
        view.addSubview(progressView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
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
    }
}
