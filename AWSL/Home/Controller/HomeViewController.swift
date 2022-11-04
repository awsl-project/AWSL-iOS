//
//  HomeViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit
import FlyUtils

class HomeViewController: PhotoListViewController {
    
    private let manager: PhotoListManager = PhotoListManager()
    
    init() {
        super.init(dataSource: manager)
        tabBarItem.image = UIImage(systemName: "photo.on.rectangle")
        tabBarItem.selectedImage = UIImage(systemName: "photo.on.rectangle.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        manager.totalContentWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func showRandomPhoto() {
        let controller = RandomPhotoViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController {
    private func setupViews() {
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationItem.title = R.string.localizable.photoList()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "dice"), style: .plain, target: self, action: #selector(showRandomPhoto))
    }
}
