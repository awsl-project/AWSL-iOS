//
//  PhotoListViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit
import SnapKit
import Alamofire

class PhotoListViewController: UIViewController {
    
    private let titleButton: UIButton = UIButton()
    private let moreItem: UIBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: nil)
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    private let producerView: UIView = UIView()
    private let producerTableView: UITableView = UITableView()
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        padding = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 64
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let maximumItemPerRow: Int = 2
    private let lineSpacing: CGFloat = 3
    private let interItemSpacing: CGFloat = 3
    private let padding: CGFloat
    
    private var isLoading: Bool = false
    private var currentTask: DataRequest?
    private var contents: [Photo] = []
    private var cellSizeMap: [String: CGSize] = [:]
    
    private var producers: [Producer] = []
    private var selectedProducerIndex: Int?
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.PLVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadProducers()
        if let manager = NetworkReachabilityManager.default, !manager.isReachable {
            manager.startListening(onUpdatePerforming: { status in
                guard case .reachable = status else { return }
                self.refreshControl.beginRefreshing()
                self.refresh()
                manager.stopListening()
            })
        } else {
            refreshControl.beginRefreshing()
            refresh()
        }
    }
    
    @objc private func toggleProducersList() {
        guard !producers.isEmpty else { return }
        let hidden = producerView.alpha == 1
        setProducersListHidden(hidden)
    }
    
    @objc private func hideProducersList(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: producerView).y > producerTableView.bounds.height else { return }
        setProducersListHidden(true)
    }
    
    private func setProducersListHidden(_ isHidden: Bool) {
        producerView.isHidden = false
        producerView.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0, options: isHidden ? .curveEaseIn : .curveEaseOut) {
            self.producerView.alpha = isHidden ? 0 : 1
            self.producerTableView.snp.updateConstraints { make in
                if isHidden {
                    make.height.equalTo(0)
                } else {
                    let maxHeight = self.view.bounds.height * 0.6
                    let height = self.producerTableView.rowHeight * CGFloat(self.producers.count)
                    make.height.equalTo(min(maxHeight, height))
                }
            }
            self.producerView.layoutIfNeeded()
        } completion: { finished in
            if isHidden {
                self.producerView.isHidden = true
            }
        }
    }
    
    private func loadProducers() {
        Network.request(Api.GetProducers()) { result in
            switch result {
            case let .success(producers):
                self.producers = producers
                self.producerTableView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func refresh() {
        loadData(offset: 0)
    }
    
    private func loadData(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        let uid: String
        if let index = selectedProducerIndex {
            uid = producers[index].uid
        } else {
            uid = ""
        }
        currentTask = Network.request(Api.GetPhotoList(uid: uid, offset: offset), queue: queue) { result in
            switch result {
            case let .success(photos):
                self.handlePhotos(photos)
                DispatchQueue.main.async {
                    if offset == 0 {
                        self.contents = photos
                        self.collectionView.reloadSections([0])
                    } else {
                        var indexPaths: [IndexPath] = []
                        for index in 0 ..< photos.count {
                            indexPaths.append(IndexPath(item: self.contents.count + index, section: 0))
                        }
                        if self.contents.count % 2 == 1 {
                            let indexPath = IndexPath(item: self.contents.count - 1, section: 0)
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                        self.contents.append(contentsOf: photos)
                        self.collectionView.insertItems(at: indexPaths)
                    }
                }
            case let .failure(error):
                print(error)
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func handlePhotos(_ photos: [Photo]) {
        var list = photos
        if contents.count % 2 == 1 {
            list.insert(contents[contents.count - 1], at: 0)
        }
        let totalWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - padding * 2 - interItemSpacing
        while !list.isEmpty {
            let leftInfo = list.removeFirst()
            if !list.isEmpty {
                let rightInfo = list.removeFirst()
                let left = leftInfo.info.large
                let right = rightInfo.info.large
                let leftScale = totalWidth / (CGFloat(left.width) + CGFloat(right.width * left.height) / CGFloat(right.height))
                let leftWidth = round(CGFloat(left.width) * leftScale)
                let rightWidth = totalWidth - leftWidth
                let height = round(CGFloat(left.height) * leftScale)
                cellSizeMap[leftInfo.id] = CGSize(width: leftWidth, height: height)
                cellSizeMap[rightInfo.id] = CGSize(width: rightWidth, height: height)
            } else {
                let largeInfo = leftInfo.info.large
                let width = totalWidth / 2
                let height = width / CGFloat(largeInfo.width) * CGFloat(largeInfo.height)
                cellSizeMap[leftInfo.id] = CGSize(width: width, height: height)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let inset = (view.bounds.width - min(view.bounds.width, view.bounds.height)) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.isEmpty ? 0 : contents.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == contents.count {
            let cell = collectionView.ch.dequeueReusableCell(LoadingCell.self, for: indexPath)
            cell.startAnimating()
            return cell
        }
        let cell = collectionView.ch.dequeueReusableCell(PhotoCell.self, for: indexPath)
        cell.imageUrl = contents[indexPath.item].info.large.url
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < contents.count else { return }
        var animationInfo: PhotoBrowserViewController.AnimationInfo?
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let image = cell.image {
            let fromRect = cell.convert(cell.bounds, to: view)
            animationInfo = PhotoBrowserViewController.AnimationInfo(image: image, fromRect: fromRect)
        }
        let controller = PhotoBrowserViewController(contents[indexPath.item], animationInfo: animationInfo)
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == contents.count {
            return CGSize(width: min(view.bounds.width, view.bounds.height) - padding * 2, height: 80)
        }
        let info = contents[indexPath.item]
        return cellSizeMap[info.id] ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == contents.count {
            loadData(offset: contents.count)
        }
    }
}

extension PhotoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return producers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.ch.dequeueReusableCell(ProducerCell.self, for: indexPath)
        cell.name = producers[indexPath.row].name
        cell.isChecked = selectedProducerIndex == indexPath.row
        return cell
    }
}

extension PhotoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggleProducersList()
        guard selectedProducerIndex != indexPath.row else { return }
        if let index = selectedProducerIndex {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ProducerCell {
                cell.isChecked = false
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) as? ProducerCell {
            cell.isChecked = true
        }
        selectedProducerIndex = indexPath.row
        contents = []
        collectionView.reloadData()
        refresh()
        titleButton.setTitle(producers[indexPath.row].name, for: .normal)
    }
}

extension PhotoListViewController {
    private func setupViews() {
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationItem.titleView = titleButton
        titleButton.setTitle("就你辣！", for: .normal)
        titleButton.setTitleColor(.label, for: .normal)
        titleButton.setTitleColor(.secondaryLabel, for: .highlighted)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        let config = UIImage.SymbolConfiguration(pointSize: 14)
        let icon = UIImage(systemName: "chevron.down", withConfiguration: config)
        titleButton.setImage(icon, for: .normal)
        titleButton.semanticContentAttribute = .forceRightToLeft
        titleButton.tintColor = .label
        titleButton.addTarget(self, action: #selector(toggleProducersList), for: .touchUpInside)
        titleButton.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 2, height: 36)
        
        moreItem.menu = buildMoreMenu()
        navigationItem.rightBarButtonItem = moreItem
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemGray6
        collectionView.ch.register(PhotoCell.self)
        collectionView.ch.register(LoadingCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: padding, bottom: 16, right: padding)
        
        producerView.isHidden = true
        producerView.alpha = 0
        
        let producerMask = UIView()
        producerMask.backgroundColor = UIColor(white: 0, alpha: 0.5)
        producerMask.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideProducersList)))
        
        producerTableView.ch.register(ProducerCell.self)
        producerTableView.dataSource = self
        producerTableView.delegate = self
        producerTableView.rowHeight = 52
        producerTableView.separatorInset = .zero
        producerTableView.backgroundColor = .systemGray6
        
        view.addSubview(collectionView)
        view.addSubview(producerView)
        producerView.addSubview(producerMask)
        producerView.addSubview(producerTableView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        producerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        producerMask.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        producerTableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    private func buildMoreMenu() -> UIMenu? {
        guard let nav = navigationController as? NavigationController else { return nil }
//        let addProducer = UIAction(title: "瑟瑟生产机", image: UIImage(systemName: "plus.circle")) { [weak self] action in
//            guard let self = self else { return }
//
//        }
        var autoMode: UIAction?
        var darkMode: UIAction?
        var lightMode: UIAction?
        autoMode = UIAction(title: "跟随系统",
                            image: UIImage(systemName: "switch.2"),
                            state: nav.themeMode == .automatic ? .on : .off) { [weak self] action in
            guard let self = self else { return }
            nav.themeMode = .automatic
            self.moreItem.menu = self.buildMoreMenu()
        }
        darkMode = UIAction(title: "深色模式",
                            image: UIImage(systemName: "moon.stars"),
                            state: nav.themeMode == .dark ? .on : .off) { [weak self] action in
            guard let self = self else { return }
            nav.themeMode = .dark
            self.moreItem.menu = self.buildMoreMenu()
        }
        lightMode = UIAction(title: "浅色模式",
                             image: UIImage(systemName: "sun.max"),
                             state: nav.themeMode == .light ? .on : .off) { [weak self] action in
            guard let self = self else { return }
            nav.themeMode = .light
            self.moreItem.menu = self.buildMoreMenu()
        }
        return UIMenu(children: [
//            addProducer,
            UIMenu(options: .displayInline, children: [autoMode!, darkMode!, lightMode!])
        ])
    }
}
