//
//  PhotoListManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit

class PhotoListManager: PhotoListDataSource {
    
    let weiboUid: String
    
    let maximumItemPerRow: Int
    
    var totalContentWidth: CGFloat = 0
    
    private(set) var photos: [Photo] = []
    
    private var isLoading: Bool = false
    private var itemSizeMap: [Photo: CGSize] = [:]
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLM")
    
    init(weiboUid: String = "") {
        self.weiboUid = weiboUid
        self.maximumItemPerRow = ThemeManager.shared.layoutMode.maximumItemPerRow
    }
    
    func hasNextPage() -> Bool {
        return true
    }
    
    func itemSize(for photo: Photo) -> CGSize {
        return itemSizeMap[photo] ?? .zero
    }
    
    func refresh(completion: @escaping LoadingCompletion) {
        loadData(offset: 0, completion: completion)
    }
    
    func loadNextPage(completion: @escaping LoadingCompletion) {
        loadData(offset: photos.count, completion: completion)
    }
    
    private func loadData(offset: Int, completion: @escaping LoadingCompletion) {
        guard !isLoading else { return }
        isLoading = true
        Network.request(Api.GetPhotoList(uid: weiboUid, offset: offset), queue: queue) { result in
            var loadingResult: Result<[IndexPath], Error>
            switch result {
            case let .success(photos):
                self.handlePhotos(photos)
                if offset == 0 {
                    self.photos = photos
                    loadingResult = .success([])
                } else {
                    let beginIndex = self.photos.count
                    self.photos.append(contentsOf: photos)
                    var indexPaths: [IndexPath] = []
                    for index in 0 ..< photos.count {
                        indexPaths.append(IndexPath(item: beginIndex + index, section: 0))
                    }
                    loadingResult = .success(indexPaths)
                }
            case let .failure(error):
                print(error)
                loadingResult = .failure(error)
            }
            self.isLoading = false
            DispatchQueue.main.async {
                completion(loadingResult)
            }
        }
    }
    
    private func handlePhotos(_ photos: [Photo]) {
        var list = photos
        if photos.count % 2 == 1 {
            list.insert(photos[photos.count - 1], at: 0)
        }
        let calculator = CellSizeCalculator(totalWidth: totalContentWidth, interval: 3)
        while !list.isEmpty {
            if maximumItemPerRow == 3 && list.count >= 3 {
                let leftInfo = list[0].info.large
                let middleInfo = list[1].info.large
                let rightInfo = list[2].info.large
                let result = calculator.calculateCellSize(leftInfo: leftInfo, middleInfo: middleInfo, rightInfo: rightInfo)
                itemSizeMap[list[0]] = result.0
                itemSizeMap[list[1]] = result.1
                itemSizeMap[list[2]] = result.2
                list.removeFirst(3)
            } else if list.count >= 2 {
                let leftInfo = list[0].info.large
                let rightInfo = list[1].info.large
                let result = calculator.calculateCellSize(leftInfo: leftInfo, rightInfo: rightInfo)
                itemSizeMap[list[0]] = result.0
                itemSizeMap[list[1]] = result.1
                list.removeFirst(2)
            } else {
                let info = list[0].info.large
                itemSizeMap[list[0]] = calculator.calculateCellSize(singleImage: info)
                list.removeFirst()
            }
        }
    }
}
