//
//  PhotoSourceViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit

class PhotoSourceViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension PhotoSourceViewController {
    private func setupViews() {
        
    }
}
