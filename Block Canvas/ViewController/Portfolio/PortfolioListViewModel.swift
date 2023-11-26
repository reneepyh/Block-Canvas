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
    
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let userDefaults = UserDefaults.standard
    
    private let apiService = PortfolioAPIService.shared
    
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
        
        print(walletAddresses)
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
    
    func updateWalletBalances() {
        walletAddresses.forEach { wallet in
            guard let address = wallet["address"] else { return }
            
            apiService.fetchWalletBalance(address: address)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        self.errorMessage = "Failed to fetch balance"
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] balanceData in
                    let confirmedBalanceInInt = Int(balanceData[0].confirmedBalance ?? "0")
                    let confirmedBalance = Decimal(confirmedBalanceInInt ?? 0)
                    let decimals = balanceData[0].currency?.decimals
                    let divisor = pow(10, decimals ?? 1)
                    let actualBalance = confirmedBalance / divisor
                    let formattedBalance = String(format: "%.5f", NSDecimalNumber(decimal: actualBalance).doubleValue)
                    
                    self?.balance[address] = formattedBalance
                })
                .store(in: &cancellables)
        }
    }
    
    func deleteWallet(at index: Int) {
        guard index < walletAddresses.count else { return }
        
        let address = walletAddresses[index]["address"]
        walletAddresses.remove(at: index)
        
        if let address = address {
            balance[address] = nil
        }
        
        userDefaults.set(walletAddresses, forKey: "walletAddress")
    }
    
    func updateWalletName(at index: Int, newName: String) {
        guard index < walletAddresses.count, !newName.isEmpty else { return }
        
        walletAddresses[index]["name"] = newName
        
        userDefaults.set(walletAddresses, forKey: "walletAddress")
    }
}
