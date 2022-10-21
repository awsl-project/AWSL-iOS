//
//  TitleValueCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/2.
//

import UIKit

class TitleValueCell: UITableViewCell {
    
    var item: NormalSection.Item? {
        didSet {
            icon = item?.icon
            title = item?.title
            value = item?.value.value
            valueObserver = item?.value.onChange { [weak self] value in
                self?.value = value
                if value.isEmpty && self?.item?.action != nil {
                    self?.accessoryType = .disclosureIndicator
                } else {
                    self?.accessoryType = .none
                }
            }
        }
    }
    
    var icon: UIImage? {
        get { iconView.image }
        set {
            iconView.image = newValue
            iconView.isHidden = newValue == nil
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    private var valueObserver: ValueObserver<String>?
    
    private let iconView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let valueLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemGray6
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        
        iconView.isHidden = true
        iconView.tintColor = .systemPink
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}
