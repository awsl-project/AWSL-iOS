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
            self?.collectionView.reloadData()
        }
    }
}

extension LikedPhotosViewController {
    private func setupViews() {
        
    }
}
