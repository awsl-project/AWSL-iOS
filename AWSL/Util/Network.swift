//
//  Network.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import Foundation
import Alamofire

protocol AwslApi: URLConvertible {
    associatedtype ResponseType: Decodable
    var path: String { get }
    var method: HTTPMethod { get }
    var header: HTTPHeaders? { get }
    var params: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

struct Api { }

class Network {
    static let domain: URL = URL(string: "https://awsl-api.aks.dreamhunter2333.com/")!
    
    @discardableResult
    static func request<Api: AwslApi>(_ api: Api,
                                      queue: DispatchQueue = .main,
                                      completion: @escaping (Result<Api.ResponseType, Error>) -> Void) -> DataRequest {
        let task = AF.request(api, method: api.method, parameters: api.params, encoding: api.encoding, headers: api.header)
        task.responseDecodable(of: Api.ResponseType.self, queue: queue) { dataResponse in
            switch dataResponse.result {
            case let .success(response):
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        if InReviewManager.shared.needsWaitReviewStatus {
            DispatchQueue.global().async {
                InReviewManager.shared.group.notify(queue: .main) {
                    task.resume()
                }
            }
            return task
        }
        task.resume()
        return task
    }
    
    static func waitForReachable(action: @escaping () -> Void) {
        if let manager = NetworkReachabilityManager(), !manager.isReachable {
            manager.startListening(onUpdatePerforming: { status in
                guard case .reachable = status else { return }
                action()
                manager.stopListening()
            })
        } else {
            action()
        }
    }
}

extension AwslApi {
    var method: HTTPMethod { .get }
    var header: HTTPHeaders? { nil }
    var params: [String: Any]? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
    func asURL() throws -> URL {
        return Network.domain.appendingPathComponent(path)
    }
}
