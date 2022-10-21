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
    
    let dataSource: PhotoListDataSource
    
    var maximumItemPerRow: Int = 2
    
    let lineSpacing: CGFloat = 3
    let interItemSpacing: CGFloat = 3
    let padding: CGFloat
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let collectionView: UICollectionView
    
    let emptyView: UIView = UIView()
    
    init(dataSource: PhotoListDataSource) {
        self.dataSource = dataSource
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        padding = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 64
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshControl.beginRefreshing()
        refresh()
    }
    
    @objc func refresh() {
        dataSource.refresh { result in
            self.emptyView.isHidden = !self.dataSource.photos.isEmpty
            self.refreshControl.endRefreshing()
            switch result {
            case .success:
                self.collectionView.reloadData()
            case let .failure(error):
                print(error)
                Toast.show(R.string.localizable.networkError())
            }
        }
    }
    
    func loadNextPage() {
        dataSource.loadNextPage { result in
            switch result {
            case let .success(indexPaths):
                self.collectionView.insertItems(at: indexPaths)
                let previousCount = self.dataSource.photos.count - indexPaths.count
                let reloadCount = previousCount % self.dataSource.maximumItemPerRow
                if reloadCount > 0 {
                    var reloadIndexPaths: [IndexPath] = []
                    for index in 0 ..< reloadCount {
                        reloadIndexPaths.append(IndexPath(item: previousCount - index - 1, section: 0))
                    }
                    self.collectionView.reloadItems(at: reloadIndexPaths)
                }
            case let .failure(error):
                print(error)
                Toast.show(R.string.localizable.networkError())
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
        let showLoadingCell = dataSource.hasNextPage() && !dataSource.photos.isEmpty
        return dataSource.photos.count + (showLoadingCell ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == dataSource.photos.count {
            let cell = collectionView.ch.dequeueReusableCell(LoadingCell.self, for: indexPath)
            cell.startAnimating()
            return cell
        }
        let cell = collectionView.ch.dequeueReusableCell(PhotoCell.self, for: indexPath)
        cell.imageUrl = dataSource.photos[indexPath.item].info.large.url
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < dataSource.photos.count else { return }
        var animationInfo: PhotoBrowserViewController.AnimationInfo?
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let image = cell.image {
            let fromRect = cell.convert(cell.bounds, to: view)
            animationInfo = PhotoBrowserViewController.AnimationInfo(image: image, fromRect: fromRect)
        }
        let controller = PhotoBrowserViewController(dataSource.photos[indexPath.item],
                                                    animationInfo: animationInfo)
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == dataSource.photos.count {
            return CGSize(width: min(view.bounds.width, view.bounds.height) - padding * 2, height: 80)
        }
        return dataSource.itemSize(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == dataSource.photos.count {
            loadNextPage()
        }
    }
}

extension PhotoListViewController {
    private func setupViews() {
        navigationController?.navigationBar.tintColor = .systemPink
        navigationItem.backButtonTitle = R.string.localizable.goBack()
        
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
        view.addSubview(emptyView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-88)
            make.centerX.equalToSuperview()
        }
    }
}
