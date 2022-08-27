//
//  ProducerCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/27.
//

import UIKit

class ProducerCell: UITableViewCell {
    
    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var isChecked = false {
        didSet {
            checkView.isHidden = !isChecked
        }
    }
    
    private let nameLabel: UILabel = UILabel()
    private let checkView: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemGray6
        
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.textColor = .label
        
        checkView.isHidden = true
        checkView.image = UIImage(systemName: "checkmark")
        checkView.tintColor = .systemGreen
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkView)
        
        nameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        checkView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(8)
        }
    }
}
