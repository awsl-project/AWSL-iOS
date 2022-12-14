//
//  SelectionCell.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/2.
//

import UIKit

class SelectionCell: UITableViewCell {
    
    var item: SelectionSection.Item? {
        didSet {
            icon = item?.icon
            title = item?.title
            isChecked = item?.isSelected.value ?? false
            checkedObserver = item?.isSelected.onChange { [weak self] value in
                self?.isChecked = value
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
    
    var isChecked: Bool = false {
        didSet {
            checkView.isHidden = !isChecked
        }
    }
    
    private var checkedObserver: ValueObserver<Bool>?
    
    private let iconView: UIImageView = UIImageView()
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
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        
        iconView.isHidden = true
        iconView.tintColor = .systemPink
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        checkView.image = UIImage(systemName: "checkmark.circle.fill")
        checkView.tintColor = .systemPink
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        contentView.addSubview(checkView)
        
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        checkView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}
