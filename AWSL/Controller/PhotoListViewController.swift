//
//  PhotoListViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit
import SnapKit
import Alamofire

class PhotoListViewController: UIViewController {
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    init() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            maximumItemPerRow = 2
        } else {
            maximumItemPerRow = ThemeManager.shared.layoutMode == .moreImage ? 3 : 2
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        padding = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 64
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "photo.on.rectangle")
        tabBarItem.selectedImage = UIImage(systemName: "photo.on.rectangle.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var maximumItemPerRow: Int
    private let lineSpacing: CGFloat = 3
    private let interItemSpacing: CGFloat = 3
    private let padding: CGFloat
    
    private var isLoading: Bool = false
    private var currentTask: DataRequest?
    private var contents: [Photo] = []
    private var cellSizeMap: [Int: CGSize] = [:]
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let manager = NetworkReachabilityManager.default, !manager.isReachable {
            manager.startListening(onUpdatePerforming: { status in
                guard case .reachable = status else { return }
                self.refreshControl.beginRefreshing()
                self.refresh()
                manager.stopListening()
            })
        } else {
            refreshControl.beginRefreshing()
            refresh()
        }
    }
    
    @objc private func refresh() {
        loadData(offset: 0)
    }
    
    private func loadData(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        currentTask = Network.request(Api.GetPhotoList(offset: offset), queue: queue) { result in
            switch result {
            case let .success(photos):
                self.handlePhotos(photos)
                DispatchQueue.main.async {
                    if offset == 0 {
                        self.contents = photos
                        self.collectionView.reloadSections([0])
                    } else {
                        var indexPaths: [IndexPath] = []
                        for index in 0 ..< photos.count {
                            indexPaths.append(IndexPath(item: self.contents.count + index, section: 0))
                        }
                        if self.contents.count % 2 == 1 {
                            let indexPath = IndexPath(item: self.contents.count - 1, section: 0)
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                        self.contents.append(contentsOf: photos)
                        self.collectionView.insertItems(at: indexPaths)
                    }
                }
            case let .failure(error):
                print(error)
                DispatchQueue.main.async {
                    Toast.show("飞到外太空去了，一会再试试吧~")
                }
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func handlePhotos(_ photos: [Photo]) {
        var list = photos
        var index = contents.count
        if contents.count % 2 == 1 {
            list.insert(contents[contents.count - 1], at: 0)
            index -= 1
        }
        let totalWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2
        let calculator = CellSizeCalculator(totalWidth: totalWidth, interval: interItemSpacing)
        while !list.isEmpty {
            if maximumItemPerRow == 3 && list.count >= 3 {
                let leftInfo = list[0].info.large
                let middleInfo = list[1].info.large
                let rightInfo = list[2].info.large
                list.removeFirst(3)
                let result = calculator.calculateCellSize(leftInfo: leftInfo, middleInfo: middleInfo, rightInfo: rightInfo)
                cellSizeMap[index] = result.0
                cellSizeMap[index + 1] = result.1
                cellSizeMap[index + 2] = result.2
                index += 3
            } else if list.count >= 2 {
                let leftInfo = list[0].info.large
                let rightInfo = list[1].info.large
                list.removeFirst(2)
                let result = calculator.calculateCellSize(leftInfo: leftInfo, rightInfo: rightInfo)
                cellSizeMap[index] = result.0
                cellSizeMap[index + 1] = result.1
                index += 2
            } else {
                let info = list.removeFirst().info.large
                cellSizeMap[index] = calculator.calculateCellSize(singleImage: info)
                index += 1
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let inset = (view.bounds.width - min(view.bounds.width, view.bounds.height)) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.isEmpty ? 0 : contents.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == contents.count {
            let cell = collectionView.ch.dequeueReusableCell(LoadingCell.self, for: indexPath)
            cell.startAnimating()
            return cell
        }
        let cell = collectionView.ch.dequeueReusableCell(PhotoCell.self, for: indexPath)
        cell.imageUrl = contents[indexPath.item].info.large.url
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < contents.count else { return }
        var animationInfo: PhotoBrowserViewController.AnimationInfo?
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let image = cell.image {
            let fromRect = cell.convert(cell.bounds, to: view)
            animationInfo = PhotoBrowserViewController.AnimationInfo(image: image, fromRect: fromRect)
        }
        let controller = PhotoBrowserViewController(contents[indexPath.item], animationInfo: animationInfo)
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == contents.count {
            return CGSize(width: min(view.bounds.width, view.bounds.height) - padding * 2, height: 80)
        }
        return cellSizeMap[indexPath.item] ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == contents.count {
            loadData(offset: contents.count)
        }
    }
}

extension PhotoListViewController {
    private func setupViews() {
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationItem.title = "就你辣！"
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemBackground
        collectionView.ch.register(PhotoCell.self)
        collectionView.ch.register(LoadingCell.self)
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
