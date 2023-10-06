//
//  PortfolioListViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import Foundation
import UIKit

class PortfolioListViewController: UIViewController {
    @IBOutlet weak var portfolioListTableView: UITableView!
    
    private let userDefaults = UserDefaults.standard
    
    private var walletAddresses: [[String: String]] = []
    
    private var balance: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupUI()
        fetchWallets()
        balance.removeAll()
        walletAddresses.forEach { wallet in
            fetchWalletBalance(address: wallet["address"] ?? "")
        }
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupTableView() {
        portfolioListTableView.delegate = self
        portfolioListTableView.dataSource = self
        portfolioListTableView.backgroundColor = .primary
        portfolioListTableView.rowHeight = UITableView.automaticDimension
        portfolioListTableView.estimatedRowHeight = 200
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        navigationController?.navigationBar.isHidden = false
        let navigationBar = self.navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .primary
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tertiary, NSAttributedString.Key.font: UIFont.main(ofSize: 28)]
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.backButtonTitle = ""
        let navigationExtendHeight: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        navigationController?.additionalSafeAreaInsets = navigationExtendHeight
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "plus.circle.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal), target: self, action: #selector(addWallet))
    }
    
    private func fetchWallets() {
        let savedWallets = UserDefaults.standard.object(forKey: "walletAddress") as? [[String: String]] ?? []
        
        if savedWallets.isEmpty {
            walletAddresses = [["address": "0x423cE4833b42b48611C662cFdc70929E3139b009", "name": "Demo Address"]]
        } else {
            walletAddresses = savedWallets
        }
        // 內建一個錢包地址，先拿掉以下判斷
        //        if ethWallets.count == 0 {
        //            guard
        //                let addressInputVC = UIStoryboard.portfolio.instantiateViewController(
        //                    withIdentifier: String(describing: AddressInputPageViewController.self)
        //                ) as? AddressInputPageViewController
        //            else {
        //                return
        //            }
        //            addressInputVC.modalPresentationStyle = .overFullScreen
        //            navigationController?.pushViewController(addressInputVC, animated: false)
        //            addressInputVC.navigationItem.hidesBackButton = true
        //        }
    }
    
    private func fetchWalletBalance(address: String) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Blockdaemon_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Blockdaemon API Key does not exist.")
            return
        }
        
        let urlString: String
        
        if address.hasPrefix("0x") {
            urlString = "https://svc.blockdaemon.com/universal/v1/ethereum/mainnet/account/\(address)"
        } else {
            urlString = "https://svc.blockdaemon.com/universal/v1/tezos/mainnet/account/\(address)"
        }
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let balanceData = try decoder.decode(WalletBalance.self, from: data)
                    print(balanceData)
                    let confirmedBalanceInInt = Int(balanceData[0].confirmedBalance ?? "0")
                    let confirmedBalance = Decimal(confirmedBalanceInInt ?? 0)
                    let decimals = balanceData[0].currency?.decimals
                    let divisor = pow(10, decimals ?? 1)
                    let actualBalance = confirmedBalance / divisor
                    let formattedBalance = String(format: "%.5f", NSDecimalNumber(decimal: actualBalance).doubleValue)
                    
                    self?.balance[address] = formattedBalance
                    
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.portfolioListTableView.reloadData()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
        
    }
    
    @objc private func addWallet() {
        guard
            let addressInputVC = UIStoryboard.portfolio.instantiateViewController(
                withIdentifier: String(describing: AddressInputPageViewController.self)
            ) as? AddressInputPageViewController
        else {
            return
        }
        addressInputVC.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(addressInputVC, animated: true)
    }
}

extension PortfolioListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        walletAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let walletCell = portfolioListTableView.dequeueReusableCell(withIdentifier: WalletListCell.reuseIdentifier, for: indexPath) as? WalletListCell else {
            fatalError("Cannot create wallet list cell.")
        }
        
        guard let address = walletAddresses[indexPath.row]["address"] else {
            fatalError("Cannot find wallet address.")
        }
        walletCell.addressLabel.text = address
        walletCell.walletNameTextField.delegate = self
        walletCell.walletNameTextField.text = walletAddresses[indexPath.row]["name"]
        walletCell.walletNameTextField.isUserInteractionEnabled = false
        if balance.count != walletAddresses.count {
            if address.hasPrefix("0x") {
                walletCell.balanceLabel.text = "-- ETH"
                walletCell.walletImageView.image = UIImage(named: "ethereum")
            } else {
                walletCell.balanceLabel.text = "-- XTZ"
                walletCell.walletImageView.image = UIImage(named: "tezos")
            }
        } else {
            if let balance = balance[address] {
                if address.hasPrefix("0x") {
                    walletCell.balanceLabel.text = "\(balance) ETH"
                    walletCell.walletImageView.image = UIImage(named: "ethereum")
                } else {
                    walletCell.balanceLabel.text = "\(balance) XTZ"
                    walletCell.walletImageView.image = UIImage(named: "tezos")
                }
            }
        }
        print(walletAddresses[indexPath.row])
        
        return walletCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortfolio" {
            let portfolioVC = segue.destination as? PortfolioDisplayViewController
            portfolioVC?.walletAddress = sender as? String
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPortfolio", sender: walletAddresses[indexPath.row]["address"])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            self?.walletAddresses.remove(at: indexPath.row)
            self?.userDefaults.set(self?.walletAddresses, forKey: "walletAddress")
            self?.portfolioListTableView.deleteRows(at: [indexPath], with: .left)
        }
        delete.backgroundColor = .systemPink
        delete.image = UIImage(systemName: "trash")
        
        let modify = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            completionHandler(true)
            if let walletListCell = self?.portfolioListTableView.cellForRow(at: indexPath) as? WalletListCell {
                walletListCell.walletNameTextField.isUserInteractionEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    walletListCell.walletNameTextField.becomeFirstResponder()
                }
            }
        }
        modify.backgroundColor = .secondaryBlur
        modify.image = UIImage(systemName: "pencil")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, modify])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
}

extension PortfolioListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newName = textField.text, !newName.isEmpty, let walletListCell = textField.superview?.superview as? WalletListCell, let indexPath = portfolioListTableView.indexPath(for: walletListCell) {
            walletAddresses[indexPath.row]["name"] = newName
            userDefaults.set(walletAddresses, forKey: "walletAddress")
        }
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }
}
