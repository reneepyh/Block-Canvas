//
//  Portfolio.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import Foundation
// MARK: - EthNFT
struct EthNFT: Codable {
    let page, pageSize: Int?
    let cursor: String?
    let result: [EthNFTResult]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case page
        case pageSize = "page_size"
        case cursor, result, status
    }
}

// MARK: - Result
struct EthNFTResult: Codable {
    let tokenAddress, tokenID, amount: String?
    let tokenHash, blockNumberMinted, blockNumber: String?
    let name, symbol: String?
    let tokenURI: String?
    let metadata, lastTokenURISync, lastMetadataSync: String?
    let minterAddress: String?
    let media: Media?
    let verifiedCollection: Bool?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
        case amount
        case tokenHash = "token_hash"
        case blockNumberMinted = "block_number_minted"
        case blockNumber = "block_number"
        case name, symbol
        case tokenURI = "token_uri"
        case metadata
        case lastTokenURISync = "last_token_uri_sync"
        case lastMetadataSync = "last_metadata_sync"
        case minterAddress = "minter_address"
        case media
        case verifiedCollection = "verified_collection"
    }
}

// MARK: - Media
struct Media: Codable {
    let parentHash: String?
    let mediaCollection: MediaCollection?
    let originalMediaURL: String?

    enum CodingKeys: String, CodingKey {
        case parentHash = "parent_hash"
        case mediaCollection = "media_collection"
        case originalMediaURL = "original_media_url"
    }
}

// MARK: - MediaCollection
struct MediaCollection: Codable {
    let low, medium, high: MediaData?
}

// MARK: - High
struct MediaData: Codable {
    let height, width: Int?
    let url: String?
}
