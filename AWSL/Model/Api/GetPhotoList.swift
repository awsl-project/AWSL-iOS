//
//  Api.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import Foundation

extension Api {
    struct GetPhotoList: AwslApi {
        let uid: String
        let offset: Int
        let limit: Int
        
        init(uid: String = "", offset: Int, limit: Int = 20) {
            self.uid = uid
            self.offset = offset
            self.limit = limit
        }
        
        typealias ResponseType = [Photo]
        var path: String {
            App.isInReview && uid.isEmpty ? "list_in_review" : "v2/list"
        }
        var params: [String : Any]? {
            [
                "uid": uid,
                "offset": offset,
                "limit": limit
            ]
        }
    }
}

struct Photo: Codable, Hashable {
    let id: String
    let weiboUrl: URL
    
    let info: InfoContainer
    
    enum CodingKeys: String, CodingKey {
        case id = "pic_id"
        case weiboUrl = "wb_url"
        case info = "pic_info"
    }
    
    struct InfoContainer: Codable, Hashable {
        let large: Info
        let original: Info
    }
    
    struct Info: Codable, Hashable {
        let url: URL
        let width: Int
        let height: Int
    }
}
