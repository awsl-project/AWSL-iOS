//
//  ValueListenable.swift
//  AWSL
//
//  Created by FlyKite on 2022/10/13.
//

import Foundation

class ValueObserver<T> {
    
    let onValueChanged: (T) -> Void
    fileprivate var onDeinit: (() -> Void)?
    
    init(onValueChanged: @escaping (T) -> Void) {
        self.onValueChanged = onValueChanged
    }
    
    deinit {
        onDeinit?()
    }
}

class ValueProvider<T> {
    
    var value: T {
        didSet {
            notifyObservers(value)
        }
    }
    
    private var observerContainers: Set<WeakContainer> = []
    
    init(value: T) {
        self.value = value
    }
    
    func onChange(_ onValueChanged: @escaping (T) -> Void) -> ValueObserver<T> {
        let observer = ValueObserver(onValueChanged: onValueChanged)
        let container = WeakContainer(observer: observer)
        observerContainers.insert(container)
        observer.onDeinit = { [weak self] in
            self?.observerContainers.remove(container)
        }
        onValueChanged(value)
        return observer
    }
    
    private func notifyObservers(_ value: T) {
        for container in observerContainers {
            container.observer?.onValueChanged(value)
        }
    }
    
    private class WeakContainer: Hashable {
        let uuid: UUID = UUID()
        weak var observer: ValueObserver<T>?
        
        init(observer: ValueObserver<T>) {
            self.observer = observer
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        
        static func == (lhs: ValueProvider<T>.WeakContainer, rhs: ValueProvider<T>.WeakContainer) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
}
