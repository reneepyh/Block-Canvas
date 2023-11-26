//
//  AddressInputViewModel.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/11/26.
//

import Foundation
import Combine

class AddressInputViewModel {
    @Published var addressInput: String = ""
    
    @Published var nameInput: String = ""
    
    private let userDefaults = UserDefaults.standard
    
    private var walletAddresses: [[String: String]] = []
    
    var validToSubmit: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($addressInput, $nameInput)
            .map { address, name in
                return !address.isEmpty && !name.isEmpty && (address.hasPrefix("0x") || address.hasPrefix("tz") || address.hasPrefix("tx"))
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        findWallets()
    }
    
    private func findWallets() {
        walletAddresses = userDefaults.object(forKey: "walletAddress") as? [[String: String]] ?? []
    }
    
    func addWallet() {
        let walletInfo = ["address": addressInput, "name": nameInput]
        walletAddresses.append(walletInfo)
        saveWallets()
    }
    
    private func saveWallets() {
        userDefaults.set(walletAddresses, forKey: "walletAddress")
    }
}
