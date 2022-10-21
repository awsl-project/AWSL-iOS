//
//  WidgetManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/10/21.
//

import Foundation

enum WidgetImageSource: String, CaseIterable {
    case fromRandomImage
    case fromCollection
}

enum WidgetRefreshInterval: Int, CaseIterable {
    case fourHours          = 4
    case sixHours           = 6
    case twelveHours        = 12
    case twentyFourHours    = 24
}

class WidgetManager {
    
    static let shared: WidgetManager = WidgetManager()
    
    @DefaultsProperty(key: "widgetImageSource",
                      suiteName: "group.com.FlyKite.AWSL",
                      defaultValue: .fromRandomImage)
    var imageSource: WidgetImageSource
    
    @DefaultsProperty(key: "widgetRefreshInterval",
                      suiteName: "group.com.FlyKite.AWSL",
                      defaultValue: .fourHours)
    var refreshInterval: WidgetRefreshInterval
    
    @DefaultsProperty(key: "currentPhoto",
                      suiteName: "group.com.FlyKite.AWSL",
                      defaultValue: nil)
    private var currentPhoto: Photo?
    
    private init() { }
}

extension WidgetImageSource: DefaultsCustomType {
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let rawValue = storableValue as? String, let source = WidgetImageSource(rawValue: rawValue) else { return nil }
        self = source
    }
}

extension WidgetRefreshInterval: DefaultsCustomType {
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let rawValue = storableValue as? Int, let source = WidgetRefreshInterval(rawValue: rawValue) else { return nil }
        self = source
    }
}
