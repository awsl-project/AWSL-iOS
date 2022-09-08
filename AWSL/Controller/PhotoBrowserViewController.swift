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
    
    private var isLiked: Bool = false
    private var likedPhoto: LikedPhoto?
    
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    private let likeButton: UIButton = UIButton()
    private let moreButton: UIButton = UIButton()
    private let progressContainer: UIView = UIView()
    private let progressView: CircleProgressView = CircleProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadImage()
        loadLikedPhoto()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private func loadImage() {
        imageView.kf.setImage(with: photo.info.original.url,
                              placeholder: animationInfo?.image,
                              options: [.transition(.fade(0.25))],
                              progressBlock: { [weak self] receivedSize, totalSize in
            guard let self = self else { return }
            self.progressView.progress = Float(receivedSize) / Float(totalSize)
        }) { [weak self] result in
            guard let self = self else { return }
            self.progressView.progress = 1
            self.setProgressHidden(true)
            switch result {
            case let .success(imageResult):
                self.scrollView.maximumZoomScale = max(1.5, imageResult.image.size.width / self.view.bounds.width)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func setProgressHidden(_ isHidden: Bool) {
        progressContainer.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.progressContainer.alpha = isHidden ? 0 : 1
        } completion: { finished in
            if isHidden {
                self.progressContainer.isHidden = true
            }
        }

    }
    
    private func loadLikedPhoto() {
        LikedPhotosManager.shared.fetchLikedPhoto(photo) { result in
            switch result {
            case let .success(likedPhoto):
                self.isLiked = likedPhoto == nil
                self.likedPhoto = likedPhoto
                self.likeButtonClicked()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func onSingleTap() {
        dismiss(animated: true)
        if isLiked && likedPhoto == nil {
            LikedPhotosManager.shared.insertLikedPhoto(photo)
        } else if !isLiked && likedPhoto != nil {
            LikedPhotosManager.shared.removeLikedPhoto(photo)
        }
    }
    
    @objc private func onDoubleTap() {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc private func likeButtonClicked() {
        isLiked.toggle()
        let imageName = isLiked ? "heart.fill" : "heart"
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        likeButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        likeButton.tintColor = isLiked ? .systemPink : .white
    }
    
    @objc private func showMoreMenu() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: R.string.localizable.savePhoto(), style: .default, handler: { action in
            self.savePhoto()
        }))
        sheet.addAction(UIAlertAction(title: R.string.localizable.showWeibo(), style: .default, handler: { action in
            UIApplication.shared.open(self.photo.weiboUrl)
        }))
        sheet.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        sheet.popoverPresentationController?.sourceRect = moreButton.bounds
        sheet.popoverPresentationController?.sourceView = moreButton
        present(sheet, animated: true)
    }
    
    private func savePhoto() {
        checkAuthorizationStatus { isLimited in
            do {
                try self.savePhotoToAlbum()
                Toast.show(R.string.localizable.saveSucceeded())
            } catch {
                print(error)
                Toast.show(R.string.localizable.saveFailed())
            }
        } denied: { msg in
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.confirm(), style: .default))
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
            case .restricted, .denied:
                denied(R.string.localizable.needPhotoPermission())
            case .authorized:
                authorized(false)
            case .limited:
                authorized(true)
            @unknown default:
                denied(R.string.localizable.unknownError())
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var frame = imageView.frame
        if imageView.frame.width < scrollView.bounds.width {
            frame.origin.x = (scrollView.bounds.width - imageView.frame.width) / 2
        } else {
            frame.origin.x = 0
        }
        if imageView.frame.height < scrollView.bounds.height {
            frame.origin.y = (scrollView.bounds.height - imageView.frame.height) / 2
        } else {
            frame.origin.y = 0
        }
        imageView.frame = frame
    }
}

extension PhotoBrowserViewController: CustomPresentableViewController {
    func presentationAnimationConfigs() -> AnimationConfig {
        var config = AnimationConfig()
        config.duration = 0.2
        config.maskType = .none
        return config
    }
    
    func presentationWillBeginTransition(type: TransitionType) {
        progressContainer.alpha = 0
        progressContainer.isHidden = true
        switch type {
        case .presenting:
            view.backgroundColor = .clear
            likeButton.alpha = 0
            moreButton.alpha = 0
            if let info = animationInfo {
                imageView.frame = info.fromRect
            }
        case .dismissing:
            view.backgroundColor = .black
            likeButton.alpha = 1
            moreButton.alpha = 1
            let frame = imageView.convert(imageView.bounds, to: view)
            imageView.removeFromSuperview()
            imageView.frame = frame
            view.addSubview(imageView)
        }
        view.layoutIfNeeded()
    }
    
    func presentationUpdateViewsForTransition(type: TransitionType,
                                              duration: TimeInterval,
                                              completeCallback: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: 0, options: type == .presenting ? .curveEaseOut : .curveEaseIn) {
            switch type {
            case .presenting:
                self.view.backgroundColor = .black
                self.moreButton.alpha = 1
                self.likeButton.alpha = 1
                if let info = self.animationInfo {
                    self.updateImageViewFrame(image: info.image)
                } else {
                    self.imageView.frame = self.view.bounds
                }
            case .dismissing:
                self.view.backgroundColor = .clear
                self.moreButton.alpha = 0
                self.likeButton.alpha = 0
                if let info = self.animationInfo {
                    self.imageView.frame = info.fromRect
                }
            }
            self.view.layoutIfNeeded()
        } completion: { finished in
            completeCallback()
        }
    }
    
    func presentationDidEndTransition(type: TransitionType, wasCancelled: Bool) {
        switch type {
        case .presenting:
            if progressView.progress < 1 {
                self.setProgressHidden(false)
            }
        case .dismissing:
            break
        }
    }
    
    private func updateImageViewFrame(image: UIImage) {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = view.bounds.width / view.bounds.height
        if imageRatio > viewRatio {
            let height = image.size.height * view.bounds.width / image.size.width
            let y = (view.bounds.height - height) / 2
            imageView.frame = CGRect(x: 0, y: y, width: view.bounds.width, height: height)
        } else if imageRatio < viewRatio {
            let width = image.size.width * view.bounds.height / image.size.height
            let x = (view.bounds.width - width) / 2
            imageView.frame = CGRect(x: 0, y: x, width: width, height: view.bounds.height)
        } else {
            imageView.frame = view.bounds
        }
    }
}

extension PhotoBrowserViewController {
    private func setupViews() {
        if let info = animationInfo {
            imageView.image = info.image
            updateImageViewFrame(image: info.image)
        }
        imageView.contentMode = .scaleAspectFit
        
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
        tap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(doubleTap)
        
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        likeButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        likeButton.tintColor = .white
        likeButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        likeButton.layer.cornerRadius = 6
        likeButton.clipsToBounds = true
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        moreButton.setImage(UIImage(systemName: "ellipsis.circle.fill", withConfiguration: config), for: .normal)
        moreButton.tintColor = .white
        moreButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        moreButton.layer.cornerRadius = 6
        moreButton.clipsToBounds = true
        moreButton.addTarget(self, action: #selector(showMoreMenu), for: .touchUpInside)
        
        let progressMask = UIView()
        progressMask.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(likeButton)
        view.addSubview(moreButton)
        view.addSubview(progressContainer)
        progressContainer.addSubview(progressMask)
        progressMask.addSubview(progressView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
        
        moreButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
        
        progressContainer.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(0)
        }
        
        progressMask.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
}
