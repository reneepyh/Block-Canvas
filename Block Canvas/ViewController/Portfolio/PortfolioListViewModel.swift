//
//  PortfolioListViewModel.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/11/25.
//

import Foundation
import Combine

class PortfolioListViewModel {
    @Published var walletAddresses: [[String: String]] = []
    
    @Published var balance: [String: String] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadWallets()
    }
    
    func loadWallets() {
        let savedWallets = UserDefaults.standard.object(forKey: "walletAddress") as? [[String: String]] ?? []
        
        if savedWallets.isEmpty {
            walletAddresses = [["address": "0xC28EbDc6affEFa2B6326D295eB2eEc89d00aFF5f", "name": "Demo Address"]]
        } else {
            walletAddresses = savedWallets
        }
        // 內建一個錢包地址，先拿掉以下判斷
        //        if walletAddresses.count == 0 {
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
        // emptyView.isHidden = !walletAddresses.isEmpty
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
                    BCProgressHUD.showFailure(text: BCConstant.internetError)
                    print(error)
                    return
                }
                
                guard let data = data else {
                    BCProgressHUD.showFailure(text: BCConstant.internetError)
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
                    BCProgressHUD.showFailure(text: BCConstant.internetError)
                    print("Error in JSON decoding.")
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    func updateWalletBalances() {
        walletAddresses.forEach { wallet in
            fetchWalletBalance(address: wallet["address"] ?? "")
        }
    }
    
    func deleteWallet(at index: Int) {
        guard index < walletAddresses.count else { return }
        
        guard let address = walletAddresses[index]["address"] else { return }
        walletAddresses.remove(at: index)
        balance[address] = nil
        
        userDefaults.set(walletAddresses, forKey: "walletAddress")
    }
    
    func updateWalletName(at index: Int, newName: String) {
        guard index < walletAddresses.count, !newName.isEmpty else { return }
        
        walletAddresses[index]["name"] = newName
        
        userDefaults.set(walletAddresses, forKey: "walletAddress")
    }
}
