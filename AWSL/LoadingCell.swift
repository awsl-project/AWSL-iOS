//
//  LoadingCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    
    func startAnimating() {
        loadingView.startAnimating()
    }
    
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
