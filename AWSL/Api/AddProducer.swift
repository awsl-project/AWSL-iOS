//
//  AddProducer.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import Foundation
import Alamofire

struct AddProducer: AwslApi {
    let uid: String
    let keyword: String
    
    typealias ResponseType = String
    var path: String { "producers" }
    var method: HTTPMethod { .post }
    var encoding: ParameterEncoding { JSONEncoding.default }
    var params: [String : Any]? {
        [
            "uid": uid,
            "keyword": keyword
        ]
    }
}
