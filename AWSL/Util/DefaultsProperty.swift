//
//  DefaultsProperty.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/31.
//

import Foundation

protocol DefaultsSupportedType { }

protocol DefaultsCustomType: DefaultsSupportedType {
    func getStorableValue() -> DefaultsSupportedType
    init?(storableValue: Any?)
}

@propertyWrapper class DefaultsProperty<ValueType: DefaultsSupportedType> {
    var key: String { keyType.key }
    let suiteName: String?
    let defaultValue: ValueType
    
    let defaults: UserDefaults
    
    private enum KeyType {
        case staticKey(key: String)
        case dynamicKey(provider: () -> String)
        
        var key: String {
            switch self {
            case let .staticKey(key): return key
            case let .dynamicKey(provider): return provider()
            }
        }
    }
    
    private let keyType: KeyType
    
    convenience init(key: String, suiteName: String? = nil, defaultValue: ValueType) {
        self.init(keyType: .staticKey(key: key), suiteName: suiteName, defaultValue: defaultValue)
    }
    
    convenience init(keyProvider: @escaping () -> String,
                     suiteName: String? = nil,
                     defaultValue: ValueType) {
        self.init(keyType: .dynamicKey(provider: keyProvider), suiteName: suiteName, defaultValue: defaultValue)
    }
    
    private init(keyType: KeyType, suiteName: String?, defaultValue: ValueType) {
        self.keyType = keyType
        self.suiteName = suiteName
        self.defaultValue = defaultValue
        if let suiteName = suiteName {
            defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            defaults = UserDefaults.standard
        }
    }
    
    private var value: ValueType?
    var wrappedValue: ValueType {
        get {
            if let value = value {
                return value
            }
            let value = defaults.value(forKey: key)
            if let storableType = ValueType.self as? DefaultsCustomType.Type {
                let result = (storableType.init(storableValue: value) as? ValueType) ?? defaultValue
                self.value = result
                return result
            } else {
                let result = value as? ValueType ?? defaultValue
                self.value = result
                return result
            }
        }
        set {
            value = newValue
            if let value = newValue as? AnyOptional, value.isNil {
                defaults.removeObject(forKey: key)
            } else if let value = newValue as? DefaultsCustomType {
                defaults.set(value.getStorableValue(), forKey: key)
            } else {
                defaults.set(newValue, forKey: key)
            }
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        return self == nil
    }
}

extension Bool: DefaultsSupportedType { }

extension Int: DefaultsSupportedType { }

extension Int8: DefaultsSupportedType { }

extension Int16: DefaultsSupportedType { }

extension Int32: DefaultsSupportedType { }

extension Int64: DefaultsSupportedType { }

extension UInt: DefaultsSupportedType { }

extension UInt8: DefaultsSupportedType { }

extension UInt16: DefaultsSupportedType { }

extension UInt32: DefaultsSupportedType { }

extension UInt64: DefaultsSupportedType { }

extension Float: DefaultsSupportedType { }

extension Double: DefaultsSupportedType { }

extension URL: DefaultsSupportedType { }

extension String: DefaultsSupportedType { }

extension Data: DefaultsSupportedType { }

extension Date: DefaultsSupportedType { }

extension Array: DefaultsSupportedType where Element: DefaultsSupportedType { }

extension Dictionary: DefaultsSupportedType where Key: DefaultsSupportedType, Value: DefaultsSupportedType { }

extension Optional: DefaultsSupportedType where Wrapped: DefaultsSupportedType { }

extension Optional: DefaultsCustomType where Wrapped: DefaultsSupportedType {
    func getStorableValue() -> DefaultsSupportedType {
        switch self {
        case .none: return Optional<Wrapped>.none
        case let .some(wrappedValue):
            if let value = wrappedValue as? DefaultsCustomType {
                return value.getStorableValue()
            } else {
                return wrappedValue
            }
        }
    }
    
    init?(storableValue: Any?) {
        if let type = Wrapped.self as? DefaultsCustomType.Type {
            self = type.init(storableValue: storableValue) as? Wrapped
        } else if let value = storableValue as? Wrapped {
            self = .some(value)
        } else {
            self = .none
        }
    }
}
