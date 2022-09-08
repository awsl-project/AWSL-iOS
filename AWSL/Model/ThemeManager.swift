//
//  ThemeManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit

enum ThemeMode: String {
    case automatic
    case dark
    case light
}

enum LayoutMode: String {
    case normal
    case compact
}

class ThemeManager {
    
    static let shared: ThemeManager = ThemeManager()
    
    var onThemeModeChanged: ((ThemeMode) -> Void)?
    
    @DefaultsProperty(key: "themeMode", defaultValue: .automatic)
    var themeMode: ThemeMode {
        didSet {
            onThemeModeChanged?(themeMode)
        }
    }
    
    @DefaultsProperty(key: "layoutMode", defaultValue: UIDevice.current.userInterfaceIdiom == .pad ? .compact : .normal)
    var layoutMode: LayoutMode
    
}

extension ThemeMode: DefaultsCustomType {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .automatic:
            return .unspecified
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let text = storableValue as? String else { return nil }
        self.init(rawValue: text)
    }
}

extension LayoutMode: DefaultsCustomType {
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let text = storableValue as? String else { return nil }
        self.init(rawValue: text)
    }
    
    var maximumItemPerRow: Int {
        switch self {
        case .normal: return 2
        case .compact: return 3
        }
    }
}
