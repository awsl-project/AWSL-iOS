//
//  WidgetSettingsViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/10/13.
//

import UIKit

class WidgetSettingsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension WidgetSettingsViewController {
    private func setupViews() {
        title = R.string.localizable.donate()
        view.backgroundColor = .systemBackground
    }
}
