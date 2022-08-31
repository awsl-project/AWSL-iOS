//
//  NavigationController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/27.
//

import UIKit

class NavigationController: UINavigationController {
    
    enum ThemeMode: String, DefaultsCustomType {
        case automatic
        case dark
        case light
        
        fileprivate var userInterfaceStyle: UIUserInterfaceStyle {
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
    
    @DefaultsProperty(key: "themeMode", defaultValue: .automatic)
    var themeMode: ThemeMode {
        didSet {
            overrideUserInterfaceStyle = themeMode.userInterfaceStyle
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = themeMode.userInterfaceStyle
        setNeedsStatusBarAppearanceUpdate()
    }
}
