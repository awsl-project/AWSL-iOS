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

class ThemeManager {
    
    static let shared: ThemeManager = ThemeManager()
    
    var onThemeModeChanged: ((ThemeMode) -> Void)?
    
    @DefaultsProperty(key: "themeMode", defaultValue: .automatic)
    var themeMode: ThemeMode {
        didSet {
            onThemeModeChanged?(themeMode)
        }
    }
    
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
