//
//  ProducersViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit

class ProducersViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")
        loadProducers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var producers: [Producer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func loadProducers() {
        Network.request(Api.GetProducers()) { result in
            switch result {
            case let .success(producers):
                self.producers = producers
            case let .failure(error):
                Toast.show("飞到外太空去了，一会再试试吧~")
                print(error)
            }
        }
    }
}

extension ProducersViewController {
    private func setupViews() {
        
    }
}
