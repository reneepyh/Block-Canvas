//
//  Portfolio.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import Foundation

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
    let contractType: ContractType?
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
        case contractType = "contract_type"
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

enum ContractType: String, Codable {
    case erc1155 = "ERC1155"
    case erc721 = "ERC721"
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
    let mimetype: Mimetype?
    let parentHash: String?
    let status: Status?
    let updatedAt: String?
    let mediaCollection: MediaCollection?
    let originalMediaURL: String?

    enum CodingKeys: String, CodingKey {
        case mimetype
        case parentHash = "parent_hash"
        case status, updatedAt
        case mediaCollection = "media_collection"
        case originalMediaURL = "original_media_url"
    }
}

struct MediaCollection: Codable {
    let low, medium, high: Size?
}

struct Size: Codable {
    let height, width: Int?
    let url: String?
}

enum Mimetype: String, Codable {
    case imageGIF = "image/gif"
    case imageJPEG = "image/jpeg"
    case imagePNG = "image/png"
}

enum Status: String, Codable {
    case processing
    case success
}

struct NormalizedMetadata: Codable {
    let name, description: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case name, description
        case image
    }
}

struct NFTInfoForDisplay {
    let url: URL
    let title: String
    let artist: String
    let description: String
    let contract: String
}
