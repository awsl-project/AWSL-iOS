//
//  NavigationController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/27.
//

import UIKit

class NavigationController: UINavigationController {
    
    enum ThemeMode {
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
    }
    
    var themeMode: ThemeMode = .automatic {
        didSet {
            overrideUserInterfaceStyle = themeMode.userInterfaceStyle
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}
