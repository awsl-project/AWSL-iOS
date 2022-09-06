//
//  GetProducers.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import Foundation

extension Api {
    struct GetProducers: AwslApi {
        typealias ResponseType = [Producer]
        var path: String {
            App.isInReview ? "producer_photos_in_review" : "producer_photos"
        }
    }
}

struct Producer: Codable {
    let uid: String
    let name: String
    let photos: [Photo]
}
