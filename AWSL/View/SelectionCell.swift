//
//  SelectionCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/2.
//

import UIKit

class SelectionCell: UITableViewCell {
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isChecked: Bool = false {
        didSet {
            checkView.isHidden = !isChecked
        }
    }
    
    private let titleLabel: UILabel = UILabel()
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
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        checkView.image = UIImage(systemName: "checkmark.circle.fill")
        checkView.tintColor = .systemPink
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        checkView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}
