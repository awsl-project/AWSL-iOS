//
//  GetInReviewInfo.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/6.
//

import Foundation

extension Api {
    struct GetInReviewInfo: AwslApi {
        typealias ResponseType = InReviewInfo
        var path: String { "in_review" }
    }
}

struct InReviewInfo: Codable {
    let version: String
}
