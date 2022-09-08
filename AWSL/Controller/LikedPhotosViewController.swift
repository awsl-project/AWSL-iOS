//
//  LikedPhotosViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit

class LikedPhotosViewController: PhotoListViewController {
    
    init() {
        super.init(dataSource: PhotoListManager())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension LikedPhotosViewController {
    private func setupViews() {
        
    }
}
