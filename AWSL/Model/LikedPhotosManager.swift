//
//  LikedPhotosManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit
import CoreData

class LikedPhotosManager: PhotoListDataSource {
    
    typealias FetchLikedPhotoCompletion = (Result<LikedPhoto?, Error>) -> Void
    
    static let shared: LikedPhotosManager = LikedPhotosManager()
    
    let maximumItemPerRow: Int
    
    var totalContentWidth: CGFloat = 0
    
    private(set) var photos: [Photo] = []
    private var likedPhotos: [LikedPhoto] = []
    private var likedPhotoMap: [String: LikedPhoto] = [:]
    
    private var isLoading: Bool = false
    private var itemSizeMap: [Photo: CGSize] = [:]
    private let context: NSManagedObjectContext
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.LPM")
    
    private init() {
        context = LikedPhotosManager.getContext()
        maximumItemPerRow = ThemeManager.shared.layoutMode.maximumItemPerRow
    }
    
    func hasNextPage() -> Bool {
        return false
    }
    
    func itemSize(for photo: Photo) -> CGSize {
        if let size = itemSizeMap[photo] {
            return size
        }
        return itemSizeMap[photo] ?? .zero
    }
    
    func refresh(completion: @escaping LoadingCompletion) {
        fetchLikedPhotos(offset: 0, completion: completion)
    }
    
    func loadNextPage(completion: @escaping LoadingCompletion) {
        fetchLikedPhotos(offset: likedPhotos.count, completion: completion)
    }
    
    func fetchLikedPhoto(_ photo: Photo, completion: @escaping FetchLikedPhotoCompletion) {
        let context = self.context
        queue.async {
            var result: Result<LikedPhoto?, Error>
            do {
                let request = LikedPhoto.fetchRequest()
                request.predicate = NSPredicate(format: "id=%@", photo.id)
                let likedPhotos = try context.fetch(request)
                result = .success(likedPhotos.first)
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func insertLikedPhoto(_ photo: Photo, completion: ((Error?) -> Void)? = nil) {
        guard likedPhotoMap[photo.id] == nil else { return }
        let context = self.context
        queue.async {
            var err: Error?
            context.performAndWait {
                do {
                    let likedPhoto = LikedPhoto(context: context)
                    likedPhoto.id = photo.id
                    likedPhoto.weiboUrl = photo.weiboUrl.path
                    
                    let largeInfo = PhotoInfo(context: context)
                    largeInfo.url = photo.info.large.url.absoluteString
                    largeInfo.width = Int64(photo.info.large.width)
                    largeInfo.height = Int64(photo.info.large.height)
                    likedPhoto.largeInfo = largeInfo
                    
                    let originalInfo = PhotoInfo(context: context)
                    originalInfo.url = photo.info.original.url.absoluteString
                    originalInfo.width = Int64(photo.info.original.width)
                    originalInfo.height = Int64(photo.info.original.height)
                    likedPhoto.originalInfo = originalInfo
                    
                    context.insert(likedPhoto)
                    try context.save()
                } catch {
                    err = error
                }
            }
            DispatchQueue.main.async {
                completion?(err)
            }
        }
    }
    
    func removeLikedPhoto(_ photo: Photo, completion: ((Error?) -> Void)? = nil) {
        guard let likedPhoto = likedPhotoMap[photo.id] else { return }
        let context = self.context
        queue.async {
            var err: Error?
            context.performAndWait {
                do {
                    context.delete(likedPhoto)
                    try context.save()
                } catch {
                    err = error
                }
            }
            DispatchQueue.main.async {
                completion?(err)
            }
        }
    }
    
    private func fetchLikedPhotos(offset: Int, completion: @escaping LoadingCompletion) {
        guard !isLoading else { return }
        isLoading = true
        queue.async {
            var loadingResult: Result<[IndexPath], Error>
            do {
                let request = LikedPhoto.fetchRequest()
                request.fetchLimit = 20
                request.fetchOffset = offset
                let likedPhotos = try self.context.fetch(request)
                let photos = self.likedPhotos.map { $0.toPhoto() }
                self.handlePhotos(photos)
                if offset == 0 {
                    self.likedPhotos = likedPhotos
                    self.photos = photos
                    loadingResult = .success([])
                } else {
                    self.likedPhotos.append(contentsOf: likedPhotos)
                    let beginIndex = self.photos.count
                    self.photos.append(contentsOf: photos)
                    var indexPaths: [IndexPath] = []
                    for index in 0 ..< photos.count {
                        indexPaths.append(IndexPath(item: beginIndex + index, section: 0))
                    }
                    loadingResult = .success(indexPaths)
                }
            } catch {
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
    
    private static func getContext() -> NSManagedObjectContext {
        var url = URL(fileURLWithPath: NSHomeDirectory())
        url.appendPathComponent("Library")
        url.appendPathComponent("Database")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        url.appendPathComponent("AWSL.sqlite")
        
        guard let modelUrl = Bundle.main.url(forResource: "AWSL", withExtension: "momd") else {
            fatalError()
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError()
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print(error)
            fatalError()
        }
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}

extension LikedPhoto {
    fileprivate func toPhoto() -> Photo {
        guard
            let largeInfo = largeInfo,
            let originalInfo = originalInfo,
            let largeUrl = URL(string: largeInfo.url ?? ""),
            let originalUrl = URL(string: originalInfo.url ?? ""),
            let weiboUrl = URL(string: weiboUrl ?? "")
        else {
            fatalError()
        }
        let large = Photo.Info(url: largeUrl,
                               width: Int(largeInfo.width),
                               height: Int(largeInfo.height))
        let original = Photo.Info(url: originalUrl,
                                  width: Int(originalInfo.width),
                                  height: Int(originalInfo.height))
        return Photo(id: id ?? "",
                     weiboUrl: weiboUrl,
                     info: Photo.InfoContainer(large: large, original: original))
    }
}
