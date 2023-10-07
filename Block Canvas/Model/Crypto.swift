//
//  Crypto.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/16.
//

import Foundation

struct EthHistoryPrice: Codable {
    let data: [EthHistoryPriceDataForDecode]
    let timestamp: Int
}

struct EthHistoryPriceDataForDecode: Codable {
    let priceUsd: String
    let time: Int
    let circulatingSupply, date: String
}

struct EthHistoryPriceData: Identifiable {
    let id = UUID()
    let price: Double
    let time: Date
    
    init(price: Double, time: Date) {
        self.price = price
        self.time = time
    }
}

struct EthCurrentPriceData: Codable {
    let symbol, price: String
}

struct EthPriceChange: Codable {
    let priceChangePercent: String
}

struct EthGasFee: Codable {
    let status, message: String?
    let result: GasFeeResult?
}

struct GasFeeResult: Codable {
    let lastBlock, safeGasPrice, proposeGasPrice, fastGasPrice: String?
    let suggestBaseFee, gasUsedRatio: String?

    enum CodingKeys: String, CodingKey {
        case lastBlock = "LastBlock"
        case safeGasPrice = "SafeGasPrice"
        case proposeGasPrice = "ProposeGasPrice"
        case fastGasPrice = "FastGasPrice"
        case suggestBaseFee, gasUsedRatio
    }
}
