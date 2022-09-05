//
//  SettingsViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit
import Kingfisher

private protocol Section {
    var title: String { get }
    var itemCount: Int { get }
}

class SettingsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "gearshape")
        tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct NormalSection: Section {
        typealias SectionItem = Item
        let title: String
        let items: [Item]
        var itemCount: Int { items.count }
        
        struct Item {
            let title: String
            var value: String
            var action: (() -> Void)?
        }
    }
    
    struct SelectionSection: Section {
        let title: String
        let items: [Item]
        var itemCount: Int { items.count }
        let onItemSelect: (Int) -> Void
        
        struct Item {
            let title: String
            var isSelected: Bool
        }
    }
    
    private let tableView: UITableView = UITableView()
    
    private var cacheSize: UInt = 0
    private var data: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func updateImageCache() {
        ImageCache.default.calculateDiskStorageSize { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(size):
                self.cacheSize = size
            case let .failure(error):
                print(error)
            }
            self.updateData()
            self.tableView.reloadData()
        }
    }
    
    private func clearImageCache() {
        let alert = UIAlertController(title: "确定清除缓存？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            DispatchQueue.global().async {
                ImageCache.default.clearDiskCache { [weak self] in
                    guard let self = self else { return }
                    self.cacheSize = 0
                    self.updateData()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func updateData() {
        var version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] {
            version.append("(\(build))")
        }
        data = []
        data.append(SelectionSection(title: "外观", items: [
            SelectionSection.Item(title: "跟随系统", isSelected: ThemeManager.shared.themeMode == .automatic),
            SelectionSection.Item(title: "深色模式", isSelected: ThemeManager.shared.themeMode == .dark),
            SelectionSection.Item(title: "浅色模式", isSelected: ThemeManager.shared.themeMode == .light),
        ], onItemSelect: { [weak self] selectedIndex in
            guard let self = self else { return }
            switch selectedIndex {
            case 0: ThemeManager.shared.themeMode = .automatic
            case 1: ThemeManager.shared.themeMode = .dark
            case 2: ThemeManager.shared.themeMode = .light
            default: return
            }
            self.updateData()
            self.tableView.reloadSections([0], with: .none)
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            data.append(SelectionSection(title: "布局", items: [
                SelectionSection.Item(title: "紧凑视图", isSelected: ThemeManager.shared.layoutMode == .moreImage),
                SelectionSection.Item(title: "宽松视图", isSelected: ThemeManager.shared.layoutMode == .normal),
            ], onItemSelect: { [weak self] selectedIndex in
                guard let self = self else { return }
                switch selectedIndex {
                case 0: ThemeManager.shared.layoutMode = .moreImage
                case 1: ThemeManager.shared.layoutMode = .normal
                default: return
                }
                self.updateData()
                self.tableView.reloadSections([0], with: .none)
            }))
        }
        let size = Double(Int(Double(self.cacheSize) / 1024 / 1024 * 100)) / 100
        let cacheSize = "\(size)M"
        data.append(NormalSection(title: "关于", items: [
            NormalSection.Item(title: "清除缓存", value: cacheSize, action: { [weak self] in
                self?.clearImageCache()
            }),
            NormalSection.Item(title: "版本", value: version, action: nil)
        ]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageCache()
    }
    
    private func selectThemeMode() {
        
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = data[indexPath.section] as? NormalSection {
            let item = section.items[indexPath.row]
            let cell = tableView.ch.dequeueReusableCell(TitleValueCell.self, for: indexPath)
            cell.title  = item.title
            cell.value = item.value
            return cell
        } else if let section = data[indexPath.section] as? SelectionSection {
            let item = section.items[indexPath.row]
            let cell = tableView.ch.dequeueReusableCell(SelectionCell.self, for: indexPath)
            cell.title = item.title
            cell.isChecked = item.isSelected
            return cell
        }
        fatalError()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let section = data[indexPath.section] as? NormalSection {
            let item = section.items[indexPath.row]
            item.action?()
        } else if let section = data[indexPath.section] as? SelectionSection {
            section.onItemSelect(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.ch.dequeueReusableView(SettingSectionHeaderView.self)
        view?.title = data[section].title
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension SettingsViewController {
    private func setupViews() {
        navigationItem.title = "设置"
        view.backgroundColor = .systemBackground
        
        tableView.ch.register(SelectionCell.self)
        tableView.ch.register(TitleValueCell.self)
        tableView.ch.register(SettingSectionHeaderView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.sectionHeaderHeight = 36
        tableView.sectionFooterHeight = 20
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
