//
//  PhotoCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    
    var imageUrl: URL? {
        didSet {
            loadingView.isHidden = false
            loadingView.startAnimating()
            imageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.25))]) { result in
                self.loadingView.stopAnimating()
                self.loadingView.isHidden = true
            }
        }
    }
    
    var image: UIImage? { imageView.image }
    
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemGray5
        
        loadingView.isHidden = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(loadingView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
