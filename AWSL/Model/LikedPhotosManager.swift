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
    
    var reloadDataCallback: (() -> Void)?
    
    private let itemsPerPage: Int
    private(set) var photos: [Photo] = []
    private var likedPhotos: [LikedPhoto] = []
    private var likedPhotoMap: [String: LikedPhoto] = [:]
    private var totalLikedPhotosCount: Int = 0
    
    private var isLoading: Bool = false
    private var itemSizeMap: [Photo: CGSize] = [:]
    private let context: NSManagedObjectContext
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.LPM")
    
    private init() {
        context = LikedPhotosManager.getContext()
        maximumItemPerRow = ThemeManager.shared.layoutMode.maximumItemPerRow
        itemsPerPage = ThemeManager.shared.layoutMode.itemsPerPage
    }
    
    func hasNextPage() -> Bool {
        return likedPhotos.count < totalLikedPhotosCount
    }
    
    func itemSize(at indexPath: IndexPath) -> CGSize {
        if let size = itemSizeMap[photos[indexPath.item]] {
            return size
        }
        let indexInRow = indexPath.item % maximumItemPerRow
        var list: [Photo] = []
        for i in 0 ..< maximumItemPerRow {
            let index = indexPath.item - indexInRow + i
            guard index < photos.count else { break }
            list.append(photos[index])
        }
        handlePhotos(list)
        return itemSizeMap[photos[indexPath.item]] ?? .zero
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
                    
                    self.likedPhotos.insert(likedPhoto, at: 0)
                    self.photos.insert(photo, at: 0)
                    self.likedPhotoMap[photo.id] = likedPhoto
                } catch {
                    err = error
                }
            }
            DispatchQueue.main.async {
                self.reloadDataCallback?()
                self.itemSizeMap = [:]
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
                    self.likedPhotoMap[photo.id] = nil
                    if let index = self.photos.firstIndex(of: photo) {
                        self.photos.remove(at: index)
                        self.likedPhotos.remove(at: index)
                    }
                } catch {
                    err = error
                }
            }
            DispatchQueue.main.async {
                self.reloadDataCallback?()
                self.itemSizeMap = [:]
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
                request.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                request.fetchLimit = self.itemsPerPage
                request.fetchOffset = offset
                self.totalLikedPhotosCount = try self.context.count(for: LikedPhoto.fetchRequest())
                let likedPhotos = try self.context.fetch(request)
                let photos = likedPhotos.map { $0.toPhoto() }
                for likedPhoto in likedPhotos {
                    self.likedPhotoMap[likedPhoto.id ?? ""] = likedPhoto
                }
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
        let calculator = CellSizeCalculator(totalWidth: totalContentWidth, interval: 3)
        let sizes = calculator.calculateCellSize(photos: photos)
        for (index, size) in sizes.enumerated() {
            itemSizeMap[photos[index]] = size
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
