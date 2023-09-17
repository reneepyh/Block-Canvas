//
//  Portfolio.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import Foundation
// MARK: - EthNFT
struct EthNFT: Codable {
    let total: Int?
    let assets: [Asset]?
}

// MARK: - Asset
struct Asset: Codable {
    let nft: EthNFTMetadata?
    let quantity: Int?
}

// MARK: - Nft
struct EthNFTMetadata: Codable {
    let blockchain, collectionName, collectionSlug, collectionOpenseaSlug: String?
    let contractType, contractAddress, tokenID, name: String?
    let description: String?
    let image: String?
    let lastSale: LastSale?

    enum CodingKeys: String, CodingKey {
        case blockchain
        case collectionName = "collection_name"
        case collectionSlug = "collection_slug"
        case collectionOpenseaSlug = "collection_opensea_slug"
        case contractType = "contract_type"
        case contractAddress = "contract_address"
        case tokenID = "token_id"
        case name, description, image
        case lastSale = "last_sale"
    }
}

// MARK: - LastSale
struct LastSale: Codable {
    let txHash: String?
    let priceToken: Double?
    let tokenSymbol, tokenContractAddress: String?
    let priceUsd: Double?
    let price: Price?
    let txURL: String?
    let time: Int?

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
        case priceToken = "price_token"
        case tokenSymbol = "token_symbol"
        case tokenContractAddress = "token_contract_address"
        case priceUsd = "price_usd"
        case price
        case txURL = "tx_url"
        case time
    }
}

// MARK: - Price
struct Price: Codable {
    let value: Double?
    let cryptoUnit: String?
    let usd, ethValue: Double?
    let paymentToken: PaymentToken?

    enum CodingKeys: String, CodingKey {
        case value
        case cryptoUnit = "crypto_unit"
        case usd
        case ethValue = "eth_value"
        case paymentToken = "payment_token"
    }
}

// MARK: - PaymentToken
struct PaymentToken: Codable {
    let address, symbol: String?
    let decimals: Int?
}

struct NFTInfoForDisplay {
    let url: URL
    let title: String
    let artist: String
    let description: String
    let contract: String
}
