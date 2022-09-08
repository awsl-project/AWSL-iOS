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
    
    private let itemsPerPage: Int
    private var isLoading: Bool = false
    private var itemSizeMap: [Photo: CGSize] = [:]
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLM")
    
    init(weiboUid: String = "") {
        self.weiboUid = weiboUid
        self.maximumItemPerRow = ThemeManager.shared.layoutMode.maximumItemPerRow
        self.itemsPerPage = ThemeManager.shared.layoutMode.itemsPerPage
    }
    
    func hasNextPage() -> Bool {
        return true
    }
    
    func itemSize(at indexPath: IndexPath) -> CGSize {
        return itemSizeMap[photos[indexPath.item]] ?? .zero
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
        Network.request(Api.GetPhotoList(uid: weiboUid, offset: offset, limit: itemsPerPage), queue: queue) { result in
            var loadingResult: Result<[IndexPath], Error>
            switch result {
            case let .success(photos):
                var photos = photos
                if offset == 0 {
                    self.photos = photos
                    loadingResult = .success([])
                } else {
                    let count = self.photos.count
                    self.photos.append(contentsOf: photos)
                    let insertCount = count % self.maximumItemPerRow
                    if insertCount > 0 {
                        for index in 0 ..< insertCount {
                            photos.insert(self.photos[count - index - 1], at: 0)
                        }
                    }
                    var indexPaths: [IndexPath] = []
                    for index in 0 ..< photos.count - insertCount {
                        indexPaths.append(IndexPath(item: count + index, section: 0))
                    }
                    loadingResult = .success(indexPaths)
                }
                self.handlePhotos(photos)
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
        let calculator = CellSizeCalculator(totalWidth: totalContentWidth, interval: 3)
        while !list.isEmpty {
            let count = min(list.count, maximumItemPerRow)
            let sizes = calculator.calculateCellSize(photos: [Photo](list[0..<count]))
            for (index, size) in sizes.enumerated() {
                itemSizeMap[list[index]] = size
            }
            list.removeFirst(count)
        }
    }
}
