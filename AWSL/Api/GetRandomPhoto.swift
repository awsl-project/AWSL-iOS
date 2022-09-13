//
//  GetRandomPhoto.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/13.
//

import Foundation

extension Api {
    struct GetRandomPhoto: AwslApi {
        typealias ResponseType = String
        var path: String { "v2/random" }
    }
}
