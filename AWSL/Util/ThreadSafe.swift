//
//  ThreadSafe.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/9.
//

import Foundation

class ThreadSafe<T> {
    var value: T {
        get { queue.sync { innerValue } }
        set {
            queue.async(flags: .barrier) {
                self.innerValue = newValue
            }
        }
    }
    
    private var innerValue: T
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.TS", attributes: .concurrent)
    
    init(_ value: T) {
        self.innerValue = value
    }
    
    func transformValue(_ action: @escaping (T) -> T) {
        queue.async(flags: .barrier) {
            self.innerValue = action(self.innerValue)
        }
    }
}
