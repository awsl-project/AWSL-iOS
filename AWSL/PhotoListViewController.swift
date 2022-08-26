//
//  PhotoListViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit
import SnapKit

class PhotoListViewController: UIViewController {
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lineSpacing: CGFloat = 2
    private let interItemSpacing: CGFloat = 2
    private let padding: CGFloat = 16
    
    private var isLoading: Bool = false
    private var contents: [WeiboInfo] = []
    private var cellSizeMap: [String: CGSize] = [:]
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData(offset: 0)
    }
    
    private func loadData(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        Network.request(GetPhotoList(offset: offset), queue: queue) { result in
            switch result {
            case let .success(infoList):
                self.handleWeiboInfo(infoList)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.collectionView.reloadData()
                }
            case let .failure(error):
                print(error)
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
        contents.append(contentsOf: infoList)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let inset = (view.bounds.width - min(view.bounds.width, view.bounds.height)) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let info = contents[indexPath.item]
        return cellSizeMap[info.pictureInfo.objectId] ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == contents.count - 1 {
            loadData(offset: contents.count)
        }
    }
}

extension PhotoListViewController {
    private func setupViews() {
        collectionView.backgroundColor = .systemGray6
        collectionView.ch.register(PhotoCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
