//
//  LikedPhotosViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit

class LikedPhotosViewController: PhotoListViewController {
    
    private let manager: LikedPhotosManager = LikedPhotosManager.shared
    
    init() {
        super.init(dataSource: manager)
        tabBarItem.image = UIImage(systemName: "heart")
        tabBarItem.selectedImage = UIImage(systemName: "heart.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        manager.totalContentWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2
        super.viewDidLoad()
        setupViews()
        
        manager.reloadDataCallback = { [weak self] in
            guard let self = self else { return }
            self.emptyView.isHidden = !self.manager.photos.isEmpty
            self.collectionView.reloadData()
        }
    }
}

extension LikedPhotosViewController {
    private func setupViews() {
        
        let config = UIImage.SymbolConfiguration(pointSize: 64)
        let emptyIcon = UIImageView()
        emptyIcon.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: config)
        emptyIcon.tintColor = .systemPink
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 6
        let emptyLabel = UILabel()
        emptyLabel.attributedText = NSAttributedString(string: R.string.localizable.emptyLikedPhotos(),
                                                       attributes: [.paragraphStyle: pStyle])
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 2
        emptyLabel.textAlignment = .center
        
        emptyView.addSubview(emptyIcon)
        emptyView.addSubview(emptyLabel)
        
        emptyIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
