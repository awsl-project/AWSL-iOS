//
//  RandomPhotoViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/14.
//

import UIKit
import WidgetKit

class RandomPhotoViewController: UIViewController {
    
    private let imageView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadImage()
    }
    
    private func loadImage() {
        RandomPhotoManager.shared.getRandomPhoto { result in
            switch result {
            case let .success(response):
                print(response.photo.id)
                self.imageView.image = response.image
                WidgetCenter.shared.reloadAllTimelines()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func refresh() {
        RandomPhotoManager.shared.invalidateRefreshDate()
        loadImage()
    }
}

extension RandomPhotoViewController {
    private func setupViews() {
        title = R.string.localizable.randomPhoto()
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFit
        
        let button = UIButton()
        button.setTitle(R.string.localizable.refreshPhoto(), for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.setTitleColor(.systemPink.withAlphaComponent(0.7), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(button)
        
        imageView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(button.snp.top).offset(-36)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(36)
        }
    }
}
