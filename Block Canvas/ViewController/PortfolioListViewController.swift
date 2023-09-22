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
    
    private var ethWallets: [String] = []
    
    private var balance: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portfolioListTableView.delegate = self
        portfolioListTableView.dataSource = self
        portfolioListTableView.rowHeight = UITableView.automaticDimension
        portfolioListTableView.estimatedRowHeight = 200
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWallet))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        findEthWallets()
        balance.removeAll()
        ethWallets.forEach { address in
            fetchWalletBalance(address: address)
        }
    }
    
    private func findEthWallets() {
        let savedWallets = UserDefaults.standard.object(forKey: "ethWallets") as? [String] ?? []
        
        if savedWallets.isEmpty {
            ethWallets = ["0x423cE4833b42b48611C662cFdc70929E3139b009"]
        } else {
            ethWallets = savedWallets
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
        
        if let url = URL(string: "https://svc.blockdaemon.com/universal/v1/ethereum/mainnet/account/\(address)") {
            
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
        ethWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let walletCell = portfolioListTableView.dequeueReusableCell(withIdentifier: WalletListCell.reuseIdentifier, for: indexPath) as? WalletListCell else {
            fatalError("Cannot create wallet list cell.")
        }
        
        let address = ethWallets[indexPath.row]
        walletCell.addressLabel.text = address
        if balance.count != ethWallets.count {
            walletCell.balanceLabel.text = ""
        } else {
            if let balance = balance[address] {
                walletCell.balanceLabel.text = "\(balance) ETH"
            }
        }
        print(ethWallets[indexPath.row])
        
        return walletCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortfolio" {
            let portfolioVC = segue.destination as? PortfolioDisplayViewController
            portfolioVC?.ethAddress = sender as? String
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPortfolio", sender: ethWallets[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "delete") { [weak self] (action, view, completionHandler) in
            self?.ethWallets.remove(at: indexPath.row)
            self?.userDefaults.set(self?.ethWallets, forKey: "ethWallets")
            self?.portfolioListTableView.deleteRows(at: [indexPath], with: .left)
            print("delete2 \(indexPath.row)")
        }
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
