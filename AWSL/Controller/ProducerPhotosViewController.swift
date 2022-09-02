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
    override var uid: String { producer.uid }
    
    init(producer: Producer) {
        self.producer = producer
        super.init()
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
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
