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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        padding = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 64
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let maximumItemPerRow: Int = 2
    private let lineSpacing: CGFloat = 3
    private let interItemSpacing: CGFloat = 3
    private let padding: CGFloat
    
    private var isLoading: Bool = false
    private var currentTask: DataRequest?
    private var contents: [WeiboInfo] = []
    private var cellSizeMap: [String: CGSize] = [:]
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshControl.beginRefreshing()
        refresh()
    }
    
    @objc private func refresh() {
        loadData(offset: 0)
    }
    
    private func loadData(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        currentTask = Network.request(GetPhotoList(offset: offset), queue: queue) { result in
            switch result {
            case let .success(infoList):
                self.handleWeiboInfo(infoList)
                DispatchQueue.main.async {
                    if offset == 0 {
                        self.contents = infoList
                        self.collectionView.reloadSections([0])
                    } else {
                        var indexPaths: [IndexPath] = []
                        for index in 0 ..< infoList.count {
                            indexPaths.append(IndexPath(item: self.contents.count + index, section: 0))
                        }
                        if self.contents.count % 2 == 1 {
                            let indexPath = IndexPath(item: self.contents.count - 1, section: 0)
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                        self.contents.append(contentsOf: infoList)
                        self.collectionView.insertItems(at: indexPaths)
                    }
                }
            case let .failure(error):
                print(error)
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func handleWeiboInfo(_ infoList: [WeiboInfo]) {
        var list = infoList
        if contents.count % 2 == 1 {
            list.insert(contents[contents.count - 1], at: 0)
        }
        let totalWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2 - interItemSpacing
        while !list.isEmpty {
            let leftInfo = list.removeFirst()
            if !list.isEmpty {
                let rightInfo = list.removeFirst()
                if let left = leftInfo.pictureInfo.large, let right = rightInfo.pictureInfo.large {
                    let leftScale = totalWidth / (CGFloat(left.width) + CGFloat(right.width * left.height) / CGFloat(right.height))
                    let leftWidth = round(CGFloat(left.width) * leftScale)
                    let rightWidth = totalWidth - leftWidth
                    let height = round(CGFloat(left.height) * leftScale)
                    cellSizeMap[leftInfo.pictureInfo.objectId] = CGSize(width: leftWidth, height: height)
                    cellSizeMap[rightInfo.pictureInfo.objectId] = CGSize(width: rightWidth, height: height)
                } else {
                    cellSizeMap[leftInfo.pictureInfo.objectId] = CGSize(width: totalWidth / 2, height: 0)
                    cellSizeMap[rightInfo.pictureInfo.objectId] = CGSize(width: totalWidth / 2, height: 0)
                }
            } else {
                if let largeInfo = leftInfo.pictureInfo.large {
                    let width = totalWidth / 2
                    let height = width / CGFloat(largeInfo.width) * CGFloat(largeInfo.height)
                    cellSizeMap[leftInfo.pictureInfo.objectId] = CGSize(width: width, height: height)
                } else {
                    cellSizeMap[leftInfo.pictureInfo.objectId] = .zero
                }
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
        cell.imageUrl = contents[indexPath.item].pictureInfo.large?.url
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == contents.count {
            return CGSize(width: min(view.bounds.width, view.bounds.height) - padding * 2, height: 80)
        }
        let info = contents[indexPath.item]
        return cellSizeMap[info.pictureInfo.objectId] ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == contents.count {
            loadData(offset: contents.count)
        }
    }
}

extension PhotoListViewController {
    private func setupViews() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemGray6
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
