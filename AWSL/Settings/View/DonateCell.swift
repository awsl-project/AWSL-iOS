//
//  DonateCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit

class DonateCell: UITableViewCell {
    
    var onPurchase: (() -> Void)?
    
    var icon: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue }
    }
    
    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var desc: String? {
        get { descLabel.text }
        set { descLabel.text = newValue }
    }
    
    var price: String? {
        get { priceButton.title(for: .normal) }
        set {
            priceButton.setTitle(newValue, for: .normal)
            loadingView.isHidden = newValue != nil
            if newValue == nil {
                loadingView.startAnimating()
            }
        }
    }
    
    private let iconView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    private let descLabel: UILabel = UILabel()
    private let priceButton: UIButton = UIButton()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        
        iconView.tintColor = .systemPink
        iconView.contentMode = .scaleAspectFit
        
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 4
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .label
        
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        
        priceButton.setTitleColor(.systemPink, for: .normal)
        priceButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        priceButton.addTarget(self, action: #selector(priceButtonClicked), for: .touchUpInside)
        priceButton.backgroundColor = .systemGray6
        priceButton.layer.cornerRadius = 18
        priceButton.layer.masksToBounds = true
        priceButton.layer.cornerCurve = .continuous
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(descLabel)
        contentView.addSubview(priceButton)
        contentView.addSubview(loadingView)
        
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        priceButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(36)
            make.width.equalTo(72)
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(priceButton)
        }
    }
    
    @objc private func priceButtonClicked() {
        onPurchase?()
    }
}
