//
//  Portfolio.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import Foundation

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

struct EthNFT: Codable {
    let page, pageSize: Int?
    let result: [EthNFTMetadata]?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case page
        case pageSize = "page_size"
        case result, status
    }
}

struct EthNFTMetadata: Codable {
    let tokenAddress, tokenID: String?
    let blockNumber, blockNumberMinted, tokenHash, amount: String?
    let possibleSpam: Bool?
    let name, symbol: String?
    let tokenURI: String?
    let metadata: String?
    var metadataObject: Metadata? {
        get {
            if let data = metadata?.data(using: .utf8) {
                return try? JSONDecoder().decode(Metadata.self, from: data)
            }
            return nil
        }
    }
    let lastTokenURISync: String?
    let lastMetadataSync: String?
    let normalizedMetadata: NormalizedMetadata?
    let media: Media?
    let verifiedCollection: Bool?
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
        case blockNumber = "block_number"
        case blockNumberMinted = "block_number_minted"
        case tokenHash = "token_hash"
        case amount
        case possibleSpam = "possible_spam"
        case name, symbol
        case tokenURI = "token_uri"
        case metadata
        case lastTokenURISync = "last_token_uri_sync"
        case lastMetadataSync = "last_metadata_sync"
        case normalizedMetadata = "normalized_metadata"
        case media
        case verifiedCollection = "verified_collection"
    }
}

struct Metadata: Codable {
    let name: String?
    let createdBy: String?
    let description: String?
    let image: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, image, description
        case createdBy = "created_by"
        case imageUrl = "image_url"
    }
}

struct Media: Codable {
    let mediaCollection: MediaCollection?
    
    enum CodingKeys: String, CodingKey {
        case mediaCollection = "media_collection"
    }
}

struct MediaCollection: Codable {
    let low, medium, high: Size?
}

struct Size: Codable {
    let height, width: Int?
    let url: String?
}

struct NormalizedMetadata: Codable {
    let name, description: String?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case name, description
        case image
    }
}

struct TezosNFT: Codable {
    let continuation: String?
    let items: [TezosNFTMetadata]?
}

struct TezosNFTMetadata: Codable {
    let id, blockchain, collection, contract: String?
    let tokenID: String?
    let creators: [Creator]?
    let meta: Meta?
    
    enum CodingKeys: String, CodingKey {
        case id, blockchain, collection, contract
        case tokenID = "tokenId"
        case creators, meta
    }
}

struct Creator: Codable {
    let account: String?
    let value: Int?
}

struct Meta: Codable {
    let name, description: String?
    let tags: [String]?
    let content: [Content]?
}

struct Content: Codable {
    let type: String?
    let url: String?
    let representation: String?
    let mimeType: String?
    let size: Int?
    let available: Bool?
    let width, height: Int?
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case url, representation, mimeType, size, available, width, height
    }
}

struct NFTInfoForDisplay: Codable, Equatable {
    let url: URL
    let title: String
    let artist: String
    let description: String
    
    static func == (lhs: NFTInfoForDisplay, rhs: NFTInfoForDisplay) -> Bool {
        return lhs.url == rhs.url && lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.description == rhs.description
    }
}
