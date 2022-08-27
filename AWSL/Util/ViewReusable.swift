//
//  ViewReusable.swift
//  AWSL
//
//  Created by FlyKite on 2022/6/1.
//

import UIKit

protocol ViewReusable {
    static var reuseIdentifier: String { get }
}

extension ViewReusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ViewReusable { }

extension UICollectionReusableView: ViewReusable { }

extension UITableViewHeaderFooterView: ViewReusable { }

struct CellHandler<V> {
    let view: V
    init(view: V) {
        self.view = view
    }
}

extension UITableView {
    var ch: CellHandler<UITableView> {
        return CellHandler<UITableView>(view: self)
    }
}

extension UICollectionView {
    var ch: CellHandler<UICollectionView> {
        return CellHandler<UICollectionView>(view: self)
    }
}

extension CellHandler where V: UITableView {
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: cellType.reuseIdentifier, ofType: "nib") != nil {
            view.register(UINib(nibName: cellType.reuseIdentifier, bundle: Bundle.main),
                          forCellReuseIdentifier: cellType.reuseIdentifier)
        } else {
            view.register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type) -> T? {
        return view.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as? T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = view.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Dequeue cell failed at (row: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func register<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            view.register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                          forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        } else {
            view.register(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T? {
        return view.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T
    }
}

enum UICollectionViewElementKind {
    case sectionHeader
    case sectionFooter
    
    fileprivate var elementKind: String {
        switch self {
        case .sectionHeader: return UICollectionView.elementKindSectionHeader
        case .sectionFooter: return UICollectionView.elementKindSectionFooter
        }
    }
}

extension CellHandler where V: UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: cellType.reuseIdentifier, ofType: "nib") != nil {
            view.register(UINib(nibName: cellType.reuseIdentifier, bundle: Bundle.main),
                          forCellWithReuseIdentifier: cellType.reuseIdentifier)
        } else {
            view.register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func register<T: UICollectionReusableView>(_ viewType: T.Type, forSupplementaryViewOfKind: String) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            view.register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                          forSupplementaryViewOfKind: forSupplementaryViewOfKind,
                          withReuseIdentifier: viewType.reuseIdentifier)
        } else {
            view.register(viewType, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = view.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Dequeue cell failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type, ofKind: String, for indexPath: IndexPath) -> T {
        if let view = view.dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T {
            return view
        } else {
            fatalError("Dequeue view failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func register<T: UICollectionReusableView>(_ viewType: T.Type, ofKind kind: UICollectionViewElementKind) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            view.register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                          forSupplementaryViewOfKind: kind.elementKind,
                          withReuseIdentifier: viewType.reuseIdentifier)
        } else {
            view.register(viewType, forSupplementaryViewOfKind: kind.elementKind, withReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type,
                                                                       ofKind kind: UICollectionViewElementKind,
                                                                       for indexPath: IndexPath) -> T {
        if let view = view.dequeueReusableSupplementaryView(ofKind: kind.elementKind,
                                                            withReuseIdentifier: viewType.reuseIdentifier,
                                                            for: indexPath) as? T {
            return view
        } else {
            fatalError("Dequeue supplementary view failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
}
