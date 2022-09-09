//
//  ProducerCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/27.
//

import UIKit

class ProducerCell: UICollectionViewCell {
    
    var producer: Producer? {
        didSet {
            nameLabel.text = producer?.name
        }
    }
    
    var onViewAllClicked: ((ProducerCell) -> Void)?
    
    private let nameLabel: UILabel = UILabel()
    private let viewAllButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        viewAllButton.setTitle("查看全部", for: .normal)
        viewAllButton.setTitleColor(.systemPink, for: .normal)
        viewAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13)
        viewAllButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: symbolConfig), for: .normal)
        viewAllButton.tintColor = .systemPink
        viewAllButton.semanticContentAttribute = .forceRightToLeft
        viewAllButton.addTarget(self, action: #selector(viewAllButtonClicked), for: .touchUpInside)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(viewAllButton)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
            make.right.lessThanOrEqualTo(viewAllButton.snp.left)
        }
        
        viewAllButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(36)
        }
    }
    
    @objc private func viewAllButtonClicked() {
        onViewAllClicked?(self)
    }
}
