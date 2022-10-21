//
//  SettingsViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/1.
//

import UIKit
import Kingfisher
import SafariServices

class SettingsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "gearshape")
        tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = UITableView()
    
    private let cacheSizeProvider: ValueProvider<String> = ValueProvider<String>(value: "")
    
    private var data: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupViews()
    }
    
    private func updateImageCache() {
        KingfisherManager.shared.cache.calculateDiskStorageSize { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(size):
                let cacheSize = Double(size) / 1024 / 1024
                self.cacheSizeProvider.value = String(format: "%.2fM", cacheSize)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func clearImageCache() {
        let alert = UIAlertController(title: R.string.localizable.clearCahceTitle(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.confirm(), style: .default, handler: { action in
            DispatchQueue.global().async {
                KingfisherManager.shared.cache.clearDiskCache { [weak self] in
                    guard let self = self else { return }
                    self.cacheSizeProvider.value = "0M"
                }
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func initData() {
        data.append(SelectionSection(title: R.string.localizable.appearance(), items: [
            SelectionSection.Item(icon: R.image.theme_automatic(),
                                  title: R.string.localizable.themeAutomatic(),
                                  isSelected: ThemeManager.shared.themeMode == .automatic),
            SelectionSection.Item(icon: R.image.theme_dark(),
                                  title: R.string.localizable.themeDark(),
                                  isSelected: ThemeManager.shared.themeMode == .dark),
            SelectionSection.Item(icon: R.image.theme_light(),
                                  title: R.string.localizable.themeLight(),
                                  isSelected: ThemeManager.shared.themeMode == .light),
        ], onItemSelect: { section, selectedIndex in
            switch selectedIndex {
            case 0: ThemeManager.shared.themeMode = .automatic
            case 1: ThemeManager.shared.themeMode = .dark
            case 2: ThemeManager.shared.themeMode = .light
            default: return
            }
            for (index, item) in section.items.enumerated() {
                item.isSelected.value = index == selectedIndex
            }
        }))
        
        data.append(SelectionSection(title: R.string.localizable.viewMode(), items: [
            SelectionSection.Item(icon: UIImage(systemName: "rectangle.grid.2x2.fill"),
                                  title: R.string.localizable.normalView(),
                                  isSelected: ThemeManager.shared.layoutMode == .normal),
            SelectionSection.Item(icon: UIImage(systemName: "rectangle.grid.3x2.fill"),
                                  title: R.string.localizable.compactView(),
                                  isSelected: ThemeManager.shared.layoutMode == .compact),
        ], onItemSelect: { section, selectedIndex in
            switch selectedIndex {
            case 0: ThemeManager.shared.layoutMode = .normal
            case 1: ThemeManager.shared.layoutMode = .compact
            default: return
            }
            Toast.show(R.string.localizable.changeViewModeTip())
            for (index, item) in section.items.enumerated() {
                item.isSelected.value = index == selectedIndex
            }
        }))
        
        data.append(NormalSection(title: R.string.localizable.about(), items: [
            NormalSection.Item(icon: R.image.tag(),
                               title: R.string.localizable.version(),
                               value: App.version),
            NormalSection.Item(icon: R.image.clear(),
                               title: R.string.localizable.clearCache(),
                               value: cacheSizeProvider,
                               action: { [weak self] in
                self?.clearImageCache()
            }),
            NormalSection.Item(icon: UIImage(systemName: "rectangle.3.group.fill"),
                               title: R.string.localizable.widgetSettings(),
                               action: { [weak self] in
                self?.navigationController?.pushViewController(WidgetSettingsViewController(), animated: true)
            }),
            NormalSection.Item(icon: R.image.donate(),
                               title: R.string.localizable.donate(),
                               action: { [weak self] in
                self?.navigationController?.pushViewController(DonateViewController(), animated: true)
            }),
            NormalSection.Item(icon: R.image.license(),
                               title: R.string.localizable.openSourceLicense(),
                               action: { [weak self] in
                self?.navigationController?.pushViewController(LicenseViewController(), animated: true)
            }),
        ]))
        
        data.append(NormalSection(title: R.string.localizable.contactUs(), items: [
            NormalSection.Item(icon: R.image.weibo(), title: "@良风生", action: {
                UIApplication.shared.open(URL(string: "https://weibo.com/u/2123032741")!)
            }),
            NormalSection.Item(icon: R.image.weibo(), title: "@而我撑伞", action: {
                UIApplication.shared.open(URL(string: "https://weibo.com/u/5731037657")!)
            })
        ]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageCache()
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
            let cell = tableView.ch.dequeueReusableCell(TitleValueCell.self, for: indexPath)
            cell.item = section.items[indexPath.row]
            return cell
        } else if let section = data[indexPath.section] as? SelectionSection {
            let cell = tableView.ch.dequeueReusableCell(SelectionCell.self, for: indexPath)
            cell.item = section.items[indexPath.row]
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
            section.onItemSelect(section, indexPath.row)
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
        navigationItem.title = R.string.localizable.settings()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemPink
        
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
