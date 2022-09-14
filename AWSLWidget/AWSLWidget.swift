//
//  AWSLWidget.swift
//  AWSLWidget
//
//  Created by FlyKite on 2022/9/13.
//

import WidgetKit
import SwiftUI
import Kingfisher

struct PhotoEntry: TimelineEntry {
    let date: Date
    let photo: Photo?
    let image: UIImage?
}

struct RandomPhotoProvider: TimelineProvider {
    
    typealias Entry = PhotoEntry
    
    typealias Completion = (Timeline<PhotoEntry>) -> ()
    
    func placeholder(in context: Context) -> PhotoEntry {
        PhotoEntry(date: Date(), photo: nil, image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PhotoEntry) -> ()) {
        let entry = PhotoEntry(date: Date(), photo: nil, image: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping Completion) {
        RandomPhotoManager.shared.getRandomPhoto(displaySize: context.displaySize) { result in
            switch result {
            case let .success(response):
                print(response.photo.id)
                let currentDate = Date()
                let entries = [
                    PhotoEntry(date: currentDate, photo: response.photo, image: response.image),
                    PhotoEntry(date: currentDate.addingTimeInterval(120), photo: response.photo, image: response.image),
                ]
                completion(Timeline(entries: entries, policy: .atEnd))
            case let.failure(error):
                print(error)
            }
        }
    }
}
