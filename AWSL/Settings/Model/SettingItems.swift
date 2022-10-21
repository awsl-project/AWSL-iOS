//
//  SettingItems.swift
//  AWSL
//
//  Created by FlyKite on 2022/10/17.
//

import UIKit

protocol Section {
    var title: String { get }
    var itemCount: Int { get }
}

struct NormalSection: Section {
    typealias SectionItem = Item
    let title: String
    let items: [Item]
    var itemCount: Int { items.count }
    
    struct Item {
        let icon: UIImage?
        let title: String
        let value: ValueProvider<String>
        let action: (() -> Void)?
        
        init(icon: UIImage? = nil, title: String, value: String = "", action: (() -> Void)? = nil) {
            self.icon = icon
            self.title = title
            self.value = ValueProvider<String>(value: value)
            self.action = action
        }
        
        init(icon: UIImage? = nil, title: String, value: ValueProvider<String>, action: (() -> Void)? = nil) {
            self.icon = icon
            self.title = title
            self.value = value
            self.action = action
        }
    }
}

struct SelectionSection: Section {
    let title: String
    let items: [Item]
    var itemCount: Int { items.count }
    let onItemSelect: (SelectionSection, Int) -> Void
    
    struct Item {
        let icon: UIImage?
        let title: String
        let isSelected: ValueProvider<Bool>
        
        init(icon: UIImage? = nil, title: String, isSelected: Bool) {
            self.icon = icon
            self.title = title
            self.isSelected = ValueProvider<Bool>(value: isSelected)
        }
        
        init(icon: UIImage? = nil, title: String, isSelected: ValueProvider<Bool>) {
            self.icon = icon
            self.title = title
            self.isSelected = isSelected
        }
    }
}
