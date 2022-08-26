//
//  Api.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import Foundation

struct GetPhotoList: AwslApi {
    let offset: Int
    let limit: Int
    
    init(offset: Int, limit: Int = 20) {
        self.offset = offset
        self.limit = limit
    }
    
    typealias ResponseType = [WeiboInfo]
    var path: String { "list" }
    var params: [String : Any]? {
        [
            "offset": offset,
            "limit": limit
        ]
    }
}

struct WeiboInfo: Codable {
    let weiboUrl: String
    let pictureInfo: Photo
    
    enum CodingKeys: String, CodingKey {
        case weiboUrl = "wb_url"
        case pictureInfo = "pic_info"
    }
}

struct Photo: Codable {
    let objectId: String
    let photoId: String
    let photoTag: Int
    let type: String
    let photoStatus: Int
    
    let thumbnail: Info?
    let middle: Info?
    let large: Info?
    let original: Info?
    let largest: Info?
    let mw2000: Info?
    
    struct Info: Codable {
        let url: URL?
        let width: Int
        let height: Int
        let cutType: Int
        
        enum CodingKeys: String, CodingKey {
            case url
            case width
            case height
            case cutType = "cut_type"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "object_id"
        case photoId = "pic_id"
        case photoTag = "photo_tag"
        case type
        case photoStatus = "pic_status"
        
        case thumbnail
        case middle = "bmiddle"
        case large
        case largest
        case original
        case mw2000
    }
}
