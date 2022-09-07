//
//  LicenseViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/7.
//

import UIKit
import SafariServices

class LicenseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = UITableView()
    
    private let libraries: [Library] = [
        (name: "Alamofire", licenseUrl: "https://raw.githubusercontent.com/Alamofire/Alamofire/master/LICENSE"),
        (name: "Kingfisher", licenseUrl: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/LICENSE"),
        (name: "SnapKit", licenseUrl: "https://raw.githubusercontent.com/SnapKit/SnapKit/develop/LICENSE"),
        (name: "R.swift", licenseUrl: "https://raw.githubusercontent.com/mac-cain13/R.swift/master/License")
    ]
    private typealias Library = (name: String, licenseUrl: String)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func openUrlInWebview(_ url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .systemPink
        present(controller, animated: true)
    }
}

extension LicenseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = libraries[indexPath.row]
        let cell = tableView.ch.dequeueReusableCell(TitleValueCell.self, for: indexPath)
        cell.title = item.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension LicenseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: libraries[indexPath.row].licenseUrl) else { return }
        openUrlInWebview(url)
    }
}

extension LicenseViewController {
    private func setupViews() {
        title = "开源许可"
        view.backgroundColor = .systemBackground
        
        tableView.ch.register(TitleValueCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
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
