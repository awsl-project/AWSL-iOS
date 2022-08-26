//
//  PhotoBrowserViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit
import Photos

class PhotoBrowserViewController: UIViewController {
    
    let photo: Photo
    let animationInfo: AnimationInfo?
    
    struct AnimationInfo {
        let image: UIImage
        let fromRect: CGRect
    }
    
    init(_ photo: Photo, animationInfo: AnimationInfo?) {
        self.photo = photo
        self.animationInfo = animationInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let animationImageView: UIImageView = UIImageView()
    private let container: UIView = UIView()
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
                              placeholder: animationInfo?.image,
                              options: [.transition(.fade(0.25))],
                              progressBlock: { [weak self] receivedSize, totalSize in
            guard let self = self else { return }
            self.progressView.progress = Float(receivedSize) / Float(totalSize)
        }) { [weak self] result in
            guard let self = self else { return }
            self.progressView.isHidden = true
            switch result {
            case let .success(imageResult):
                self.scrollView.maximumZoomScale = max(1.5, imageResult.image.size.width / self.view.bounds.width)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func onSingleTap() {
        dismiss(animated: true)
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
        checkAuthorizationStatus { isLimited in
            do {
                try self.savePhotoToAlbum()
                Toast.show("保存成功")
            } catch {
                print(error)
                Toast.show("保存失败")
            }
        } denied: { msg in
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func checkAuthorizationStatus(authorized: @escaping (_ isLimited: Bool) -> Void,
                                          denied: @escaping (_ msg: String) -> Void) {
        checkStatus(PHPhotoLibrary.authorizationStatus())
        func checkStatus(_ status: PHAuthorizationStatus) {
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization() { status in
                    DispatchQueue.main.async {
                        checkStatus(status)
                    }
                }
            case .restricted:
                denied("请允许 AWSL 访问您的相册")
            case .denied:
                denied("请允许 AWSL 访问您的相册")
            case .authorized:
                authorized(false)
            case .limited:
                authorized(true)
            @unknown default:
                denied("未知错误")
            }
        }
    }
    
    private func savePhotoToAlbum() throws {
        guard let image = imageView.image, let collection = try findAwslAlbum() else {
            return
        }
        var placeholder: PHObjectPlaceholder?
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholder = request.placeholderForCreatedAsset
        }
        guard let placeholder = placeholder else {
            return
        }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.addAssets(assets)
        }
    }
    
    private func findAwslAlbum() throws -> PHAssetCollection? {
        let title = "AWSL"
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var targetCollection: PHAssetCollection?
        collections.enumerateObjects { collection, index, stop in
            if collection.localizedTitle == title {
                targetCollection = collection
                stop.pointee = ObjCBool(true)
            }
        }
        if let targetCollection = targetCollection {
            return targetCollection
        }
        var placeholder: PHObjectPlaceholder?
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            placeholder = request.placeholderForCreatedAssetCollection
        }
        guard let identifier = placeholder?.localIdentifier else { return nil }
        return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil).firstObject
    }
}

extension PhotoBrowserViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension PhotoBrowserViewController: CustomPresentableViewController {
    func presentationAnimationConfigs() -> AnimationConfig {
        var config = AnimationConfig()
        config.duration = 0.2
        config.maskType = .black(alpha: 1)
        return config
    }
    
    func presentationWillBeginTransition(type: TransitionType) {
        if animationInfo != nil {
            animationImageView.isHidden = false
            container.isHidden = true
        } else {
            container.alpha = 0
        }
    }
    
    func presentationUpdateViewsForTransition(type: TransitionType,
                                              duration: TimeInterval,
                                              completeCallback: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: 0, options: type == .presenting ? .curveEaseOut : .curveEaseIn) {
            if let info = self.animationInfo {
                switch type {
                case .presenting:
                    self.animationImageView.frame = self.view.bounds
                case .dismissing:
                    self.animationImageView.frame = info.fromRect
                }
            } else {
                switch type {
                case .presenting:
                    self.container.alpha = 1
                case .dismissing:
                    self.container.alpha = 0
                }
            }
        } completion: { finished in
            if self.animationInfo != nil {
                self.animationImageView.isHidden = true
                self.container.isHidden = false
            }
            completeCallback()
        }

    }
    
    func presentationDidEndTransition(type: TransitionType, wasCancelled: Bool) {
        container.isHidden = false
    }
}

extension PhotoBrowserViewController {
    private func setupViews() {
        if let info = animationInfo {
            animationImageView.frame = info.fromRect
            animationImageView.contentMode = .scaleAspectFit
            animationImageView.image = info.image
            view.addSubview(animationImageView)
        }
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
        tap.require(toFail: doubleTap)
        imageView.addGestureRecognizer(tap)
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
        
        view.addSubview(container)
        container.addSubview(progressView)
        container.addSubview(scrollView)
        scrollView.addSubview(imageView)
        container.addSubview(moreButton)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
            make.bottom.right.equalTo(container.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
    }
}
