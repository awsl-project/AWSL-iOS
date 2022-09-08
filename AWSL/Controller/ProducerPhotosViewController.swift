//
//  ProducerPhotosViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/2.
//

import UIKit
import Alamofire

class ProducerPhotosViewController: PhotoListViewController {
    
    let producer: Producer
    
    private let manager: PhotoListManager
    
    init(producer: Producer) {
        self.producer = producer
        self.manager = PhotoListManager(weiboUid: producer.uid)
        super.init(dataSource: manager)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        manager.totalContentWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ProducerPhotosViewController {
    private func setupViews() {
        navigationItem.title = producer.name
    }
}
