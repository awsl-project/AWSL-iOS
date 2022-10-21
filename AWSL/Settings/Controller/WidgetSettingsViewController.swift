//
//  WidgetSettingsViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/10/13.
//

import UIKit

class WidgetSettingsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = UITableView()
    
    private let data: [Section] = [
        SelectionSection(title: R.string.localizable.widgetImageSource(),
                         items: [
                            SelectionSection.Item(title: R.string.localizable.fromRandomImage(), isSelected: true),
                            SelectionSection.Item(title: R.string.localizable.fromCollection(), isSelected: false),
                         ],
                         onItemSelect: { section, selectedIndex in
                             for (index, item) in section.items.enumerated() {
                                 item.isSelected.value = index == selectedIndex
                             }
                         }),
        SelectionSection(title: R.string.localizable.refreshInterval(),
                         items: [
                            SelectionSection.Item(title: R.string.localizable.fourHours(), isSelected: false),
                            SelectionSection.Item(title: R.string.localizable.sixHours(), isSelected: false),
                            SelectionSection.Item(title: R.string.localizable.twelveHours(), isSelected: false),
                            SelectionSection.Item(title: R.string.localizable.twentyFourHours(), isSelected: true),
                         ],
                         onItemSelect: { section, selectedIndex in
                             for (index, item) in section.items.enumerated() {
                                 item.isSelected.value = index == selectedIndex
                             }
                         })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension WidgetSettingsViewController: UITableViewDataSource {
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

extension WidgetSettingsViewController: UITableViewDelegate {
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

extension WidgetSettingsViewController {
    private func setupViews() {
        title = R.string.localizable.widgetSettings()
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
