//
//  ProducersViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit

class ProducersViewController: UIViewController {
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        padding = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 64
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")
        loadProducers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    private let lineSpacing: CGFloat = 3
    private let interItemSpacing: CGFloat = 3
    private let padding: CGFloat
    
    private var producers: [Producer] = []
    private var cellSizeMap: [String: CGSize] = [:]
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func refresh() {
        loadProducers()
    }
    
    private func loadProducers() {
        Network.request(Api.GetProducers(), queue: queue) { result in
            switch result {
            case let .success(producers):
                for producer in producers {
                    self.handlePhotos(producer.photos)
                }
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.producers = producers
                    self.collectionView.reloadData()
                }
            case let .failure(error):
                print(error)
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    Toast.show(R.string.localizable.networkError())
                }
            }
        }
    }
    
    private func handlePhotos(_ photos: [Photo]) {
        let totalWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2
        let calculator = CellSizeCalculator(totalWidth: totalWidth, interval: interItemSpacing)
        if photos.count >= 3 {
            let leftInfo = photos[0].info.large
            let middleInfo = photos[1].info.large
            let rightInfo = photos[2].info.large
            let result = calculator.calculateCellSize(leftInfo: leftInfo, middleInfo: middleInfo, rightInfo: rightInfo)
            cellSizeMap[photos[0].id] = result.0
            cellSizeMap[photos[1].id] = result.1
            cellSizeMap[photos[2].id] = result.2
        } else if photos.count == 2 {
            let leftInfo = photos[0].info.large
            let rightInfo = photos[1].info.large
            let result = calculator.calculateCellSize(leftInfo: leftInfo, rightInfo: rightInfo)
            cellSizeMap[photos[0].id] = result.0
            cellSizeMap[photos[1].id] = result.1
        } else if photos.count == 1 {
            let info = photos[0].info.large
            cellSizeMap[photos[0].id] = calculator.calculateCellSize(singleImage: info)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let inset = (view.bounds.width - min(view.bounds.width, view.bounds.height)) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension ProducersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return producers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let producer = producers[section]
        return producer.photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let producer = producers[indexPath.section]
        if indexPath.item == 0 {
            let cell = collectionView.ch.dequeueReusableCell(ProducerCell.self, for: indexPath)
            cell.producer = producer
            cell.onViewAllClicked = { [weak self] cell in
                guard let self = self else { return }
                let controller = ProducerPhotosViewController(producer: producer)
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        }
        let photo = producer.photos[indexPath.item - 1]
        let cell = collectionView.ch.dequeueReusableCell(PhotoCell.self, for: indexPath)
        cell.imageUrl = photo.info.large.url
        return cell
    }
}

extension ProducersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item > 0 else { return }
        let producer = producers[indexPath.section]
        let photo = producer.photos[indexPath.item - 1]
        var animationInfo: PhotoBrowserViewController.AnimationInfo?
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let image = cell.image {
            let fromRect = cell.convert(cell.bounds, to: view)
            animationInfo = PhotoBrowserViewController.AnimationInfo(image: image, fromRect: fromRect)
        }
        let controller = PhotoBrowserViewController(photo, animationInfo: animationInfo)
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = min(view.bounds.width, view.bounds.height) - padding * 2
        if indexPath.item == 0 {
            return CGSize(width: width, height: 72)
        }
        let producer = producers[indexPath.section]
        let photo = producer.photos[indexPath.item - 1]
        return cellSizeMap[photo.id] ?? .zero
    }
}

extension ProducersViewController {
    private func setupViews() {
        navigationItem.backButtonTitle = R.string.localizable.goBack()
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemBackground
        collectionView.ch.register(PhotoCell.self)
        collectionView.ch.register(ProducerCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: padding, bottom: 16, right: padding)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
