//
//  Wallet.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/18.
//

import Foundation

// MARK: - WalletBalanceElement
struct WalletBalanceElement: Codable {
    let currency: Currency?
    let confirmedBalance, pendingBalance: String?
    let confirmedNonce, confirmedBlock: Int?

    enum CodingKeys: String, CodingKey {
        case currency
        case confirmedBalance = "confirmed_balance"
        case pendingBalance = "pending_balance"
        case confirmedNonce = "confirmed_nonce"
        case confirmedBlock = "confirmed_block"
    }
}

// MARK: - Currency
struct Currency: Codable {
    let assetPath, symbol, name: String?
    let decimals: Int?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case assetPath = "asset_path"
        case symbol, name, decimals, type
    }
}

typealias WalletBalance = [WalletBalanceElement]
