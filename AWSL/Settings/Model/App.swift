//
//  App.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/6.
//

import Foundation

class App {
    static let version: String = {
        return "\(shortVersion)\(build.isEmpty ? "" : "(\(build))")"
    }()
    
    #if DEBUG
    static let isInReview: Bool = false
    #else
    @DefaultsProperty(key: "isInReview", defaultValue: true)
    static fileprivate(set) var isInReview: Bool
    #endif
    
    fileprivate static let shortVersion: String = {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()
    fileprivate static let build: String = {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }()
}

class InReviewManager {
    
    static let shared: InReviewManager = InReviewManager()
    
    private init() { }
    
    private(set) var needsWaitReviewStatus = true
    let group: DispatchGroup = DispatchGroup()
    
    func checkReviewStatus() {
        #if DEBUG
        needsWaitReviewStatus = false
        #else
        guard App.isInReview else {
            needsWaitReviewStatus = false
            return
        }
        group.enter()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        Network.waitForReachable {
            Network.request(Api.GetInReviewInfo()) { result in
                switch result {
                case let .success(info):
                    App.isInReview = info.version == version
                case let .failure(error):
                    print(error)
                }
                self.needsWaitReviewStatus = false
                self.group.leave()
            }
        }
        #endif
    }
}
