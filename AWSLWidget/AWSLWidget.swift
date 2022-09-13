//
//  AWSLWidget.swift
//  AWSLWidget
//
//  Created by FlyKite on 2022/9/13.
//

import WidgetKit
import SwiftUI
import Kingfisher

struct RandomPhotoProvider: TimelineProvider {
    
    typealias Entry = PhotoEntry
    
    typealias Completion = (Timeline<PhotoEntry>) -> ()
    
    func placeholder(in context: Context) -> PhotoEntry {
        PhotoEntry(date: Date(), image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PhotoEntry) -> ()) {
        let entry = PhotoEntry(date: Date(), image: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping Completion) {
        RandomPhotoManager.shared.loadPhoto { result in
            switch result {
            case let .success(image):
                let currentDate = Date()
                let entries = [
                    PhotoEntry(date: currentDate, image: image),
                    PhotoEntry(date: currentDate.addingTimeInterval(120), image: image),
                ]
                completion(Timeline(entries: entries, policy: .atEnd))
            case let.failure(error):
                print(error)
            }
        }
    }
}

struct PhotoEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

private class RandomPhotoManager {
    
    static let shared: RandomPhotoManager = RandomPhotoManager()
    
    typealias Completion = (Result<UIImage?, Error>) -> Void
    
    @DefaultsProperty(key: "lastPhotoUrl", defaultValue: nil)
    private var lastPhotoUrl: String?
    
    @DefaultsProperty(key: "nextRefreshDate", defaultValue: Date(timeIntervalSince1970: 0))
    private var nextRefreshDate: Date
    
    private var lastImage: UIImage?
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.AWSLWidget.RPM", attributes: .concurrent)
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private init() { }
    
    func loadPhoto(completion: @escaping Completion) {
        queue.async {
            self.semaphore.wait()
            if let urlString = self.lastPhotoUrl, Date() <= self.nextRefreshDate {
                if let image = self.lastImage {
                    self.log("use last photo")
                    completion(.success(image))
                    self.semaphore.signal()
                } else if let url = URL(string: urlString) {
                    self.log("download last photo")
                    self.downloadImage(url: url, completion: completion)
                } else {
                    self.log("last photo not found")
                    completion(.success(nil))
                    self.semaphore.signal()
                }
            } else {
                self.requestRandomPhoto(completion: completion)
            }
        }
    }
    
    private func requestRandomPhoto(completion: @escaping Completion) {
        log("request random photo")
        Network.request(Api.GetRandomPhoto()) { result in
            switch result {
            case let .success(urlString):
                self.log("random photo url = \(urlString)")
                guard let url = URL(string: urlString) else {
                    self.log("url convert failed")
                    completion(.failure(NSError(domain: "url convert failed", code: -9999)))
                    self.semaphore.signal()
                    return
                }
                self.lastPhotoUrl = urlString
                self.nextRefreshDate = Date(timeIntervalSinceNow: 120)
                self.downloadImage(url: url, completion: completion)
            case let .failure(error):
                self.log("request random photo failed: \(error)")
                completion(.failure(error))
                self.semaphore.signal()
            }
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping Completion) {
        log("download image: \(url)")
        KingfisherManager.shared.retrieveImage(with: url) { imageResult in
            switch imageResult {
            case let .success(imageInfo):
                self.log("download image success")
                self.lastImage = imageInfo.image
                completion(.success(imageInfo.image))
            case let .failure(error):
                self.log("download image failed: \(error)")
                completion(.failure(error))
            }
            self.semaphore.signal()
        }
    }
    
    private func log(_ msg: Any?) {
        #if DEBUG
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let msg = msg {
            print("\(fmt.string(from: Date())): \(msg)")
        } else {
            print("\(fmt.string(from: Date())): nil")
        }
        #endif
    }
}
