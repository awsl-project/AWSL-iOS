//
//  RandomPhotoManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/14.
//

import UIKit
import Kingfisher

class RandomPhotoManager {
    
    static let shared: RandomPhotoManager = RandomPhotoManager()
    
    typealias Completion = (Result<Response, Error>) -> Void
    
    struct Response {
        let photo: Photo
        let image: UIImage?
    }
    
    @DefaultsProperty(key: "lastPhoto",
                      suiteName: "group.com.FlyKite.AWSL",
                      defaultValue: nil)
    private var lastPhoto: Photo?
    
    @DefaultsProperty(key: "nextRefreshDate",
                      suiteName: "group.com.FlyKite.AWSL",
                      defaultValue: Date(timeIntervalSince1970: 0))
    private var nextRefreshDate: Date
    
    private var lastRandomPhoto: RandomPhoto?
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.RPM", attributes: .concurrent)
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private init() { }
    
    func getRandomPhoto(displaySize: CGSize? = nil, completion: @escaping Completion) {
        queue.async {
            self.semaphore.wait()
            let callback: (Result<Response, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            let handler: (Result<RandomPhoto, Error>) -> Void = { result in
                let responseResult: Result<Response, Error>
                switch result {
                case let .success(randomPhoto):
                    self.lastPhoto = randomPhoto.photo
                    self.lastRandomPhoto = randomPhoto
                    self.nextRefreshDate = Date(timeIntervalSinceNow: 120)
                    let image: UIImage?
                    if let displaySize = displaySize {
                        image = randomPhoto.getImage(displaySize: displaySize)
                    } else {
                        image = randomPhoto.originalImage
                    }
                    let response = Response(photo: randomPhoto.photo, image: image)
                    responseResult = .success(response)
                case let .failure(error):
                    responseResult = .failure(error)
                }
                callback(responseResult)
                self.semaphore.signal()
            }
            if Date() < self.nextRefreshDate {
                if let lastRandomPhoto = self.lastRandomPhoto {
                    let image: UIImage?
                    if let displaySize = displaySize {
                        image = lastRandomPhoto.getImage(displaySize: displaySize)
                    } else {
                        image = lastRandomPhoto.originalImage
                    }
                    let response = Response(photo: lastRandomPhoto.photo, image: image)
                    callback(.success(response))
                    self.semaphore.signal()
                } else if let photo = self.lastPhoto {
                    self.download(photo: photo, completion: handler)
                } else {
                    self.requestRandomPhoto(completion: handler)
                }
            } else {
                self.requestRandomPhoto(completion: handler)
            }
        }
    }
    
    func invalidateRefreshDate() {
        nextRefreshDate = Date(timeIntervalSince1970: 0)
    }
    
    private func requestRandomPhoto(completion: @escaping (Result<RandomPhoto, Error>) -> Void) {
        Network.request(Api.GetRandomPhoto(), queue: queue) { result in
            self.queue.async {
                switch result {
                case let .success(photo):
                    self.download(photo: photo, completion: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    fileprivate func download(photo: Photo, completion: @escaping (Result<RandomPhoto, Error>) -> Void) {
        let url = photo.info.original.url
        KingfisherManager.shared.retrieveImage(with: url) { imageResult in
            switch imageResult {
            case let .success(imageInfo):
                let image = imageInfo.image
                let randomPhoto = RandomPhoto(photo: photo, originalImage: image)
                completion(.success(randomPhoto))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class RandomPhoto {
    let photo: Photo
    let originalImage: UIImage
    
    private var imageMap: [String: UIImage] = [:]
    
    init(photo: Photo, originalImage: UIImage) {
        self.photo = photo
        self.originalImage = originalImage
    }
    
    func getImage(displaySize: CGSize) -> UIImage? {
        let key = "\(Int(displaySize.width))*\(Int(displaySize.height))"
        if let image = imageMap[key] {
            return image
        }
        let image = cropAndResize(image: originalImage, to: displaySize)
        imageMap[key] = image
        return image
    }
    
    private func cropAndResize(image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let targetRatio = size.width / size.height
        let imageRatio = image.size.width / image.size.height
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = size.width
        var height: CGFloat = size.height
        if imageRatio > targetRatio {
            width = image.size.width * size.height / image.size.height
            x = (size.width - width) / 2
        } else if imageRatio < targetRatio {
            height = image.size.height * size.width / image.size.width
            y = (size.height - height) / 2
        }
        image.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
