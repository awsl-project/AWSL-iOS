//
//  DonateViewController.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit
import StoreKit

enum PaymentItem: String {
    case donateMilk     = "AWSL_Donate_Milk"
    case donateCoffee   = "AWSL_Donate_Coffee"
}

class DonateViewController: UIViewController {
    
    private let tableView = UITableView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class DonateItem {
        let icon: UIImage?
        let name: String
        let desc: String
        var price: String?
        var product: SKProduct?
        init(icon: UIImage?, name: String, desc: String) {
            self.icon = icon
            self.name = name
            self.desc = desc
        }
    }
    
    private let group: DispatchGroup = DispatchGroup()
    private var donateItems: [DonateItem] = [
        DonateItem(icon: R.image.milk(),
                   name: R.string.localizable.donateMilk(),
                   desc: R.string.localizable.donateMilkDesc()),
        DonateItem(icon: R.image.coffee(),
                   name: R.string.localizable.donateCoffee(),
                   desc: R.string.localizable.donateCoffeeDesc()),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadPrice()
    }
    
    private func loadPrice() {
        group.enter()
        let request = SKProductsRequest(productIdentifiers: [PaymentItem.donateMilk.productId,
                                                             PaymentItem.donateCoffee.productId])
        request.delegate = self
        request.start()
    }
    
    private func startDonate(_ donateItem: DonateItem) {
        guard let product = donateItem.product else {
            return
        }
        guard SKPaymentQueue.canMakePayments() else {
            Toast.show(R.string.localizable.donateUnavailable())
            return
        }
        group.notify(queue: .main) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    private func donateSucceeded() {
        let alert = UIAlertController(title: R.string.localizable.thanksForDonate(),
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.confirm(), style: .default))
        present(alert, animated: true)
    }
    
    private func donateFailed(_ message: String) {
        let alert = UIAlertController(title: R.string.localizable.purchaseFailed(),
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.confirm(), style: .default))
        present(alert, animated: true)
    }
}

extension DonateViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            guard let paymentItem = PaymentItem(rawValue: product.productIdentifier) else { continue }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            guard let formattedString = formatter.string(from: product.price) else { continue }
            switch paymentItem {
            case .donateMilk:
                donateItems[0].price = formattedString
                donateItems[0].product = product
            case .donateCoffee:
                donateItems[1].price = formattedString
                donateItems[1].product = product
            }
        }
        group.leave()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DonateViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                queue.finishTransaction(transaction)
                donateSucceeded()
            case .failed:
                var message = R.string.localizable.purchaseFailed()
                if let error = transaction.error as NSError? {
                    message = error.localizedDescription
                    print(error.localizedDescription)
                }
                queue.finishTransaction(transaction)
                donateFailed(message)
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}

extension DonateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donateItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.fl.dequeueReusableCell(DonateCell.self, for: indexPath)
        cell.icon = donateItems[indexPath.row].icon
        cell.name = donateItems[indexPath.row].name
        cell.desc = donateItems[indexPath.row].desc
        cell.price = donateItems[indexPath.row].price
        cell.onPurchase = { [weak self] in
            guard let self = self else { return }
            self.startDonate(self.donateItems[indexPath.row])
        }
        return cell
    }
}

extension DonateViewController {
    private func setupViews() {
        title = R.string.localizable.donate()
        view.backgroundColor = .systemBackground
        SKPaymentQueue.default().add(self)
        
        tableView.fl.register(DonateCell.self)
        tableView.dataSource = self
        tableView.rowHeight = 88
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

extension PaymentItem {
    var productId: String { rawValue }
}
