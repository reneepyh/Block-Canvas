//
//  Discover.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

struct TrendingNFT {
    let ipfsURL: String
    let title: String
    let authorName: String
    
}

struct OpenAIBody: Encodable {
    let model: String = "gpt-4"
    let messages: [[String: String]]
    let temperature = 0.0
    let maxTokens = 300
    let topP = 1.0
    let frequencyPenalty = 0.0
    let presencePenalty = 0.0
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]?
}

struct Choice: Codable {
    let message: Message?

    enum CodingKeys: String, CodingKey {
        case message
    }
}

struct Message: Codable {
    let role, content: String?
}

struct ArtCollection {
    let collectionName: String
}

struct SearchedNFT: Codable {
    let total: Int?
    let collections: [Collection]?
}

struct Collection: Codable {
    let lastUpdated: Int?
    let collectionID, blockchain, name, slug: String?
    let openseaSlug, description: String?
    let openseaURL, logo: String?
    let contracts: [String]?
    let categories: [String]?

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case collectionID = "collection_id"
        case blockchain, name, slug
        case openseaSlug = "opensea_slug"
        case description
        case openseaURL = "opensea_url"
        case logo, contracts
        case categories
    }
}

struct GetNFTByContract: Codable {
    let page, pageSize: Int?
    let cursor: String?
    let result: [Result]?

    enum CodingKeys: String, CodingKey {
        case page
        case pageSize = "page_size"
        case cursor, result
    }
}

struct Result: Codable {
    let tokenAddress, tokenID, amount: String?
    let name, symbol: String?
    let metadata: String?
    let minterAddress: String?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
        case amount
        case name, symbol
        case metadata
        case minterAddress = "minter_address"
    }
}

struct NFTForFetch: Codable {
    let tokenAddress: String
    let tokenID: String
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
    }
}

// MARK: - NFTMetadatum
struct NFTMetadatum: Codable {
    let tokenAddress, tokenID: String?
//    let transferIndex: [Int]?
//    let ownerOf, blockNumber, blockNumberMinted, tokenHash: String?
//    let amount, updatedAt, contractType: String?
//    let tokenURI, metadata, lastTokenURISync, lastMetadataSync: String?
//    let minterAddress: String?
//    let normalizedMetadata: NormalizedMetadata?
//    let media: Media?
//    let possibleSpam, verifiedCollection: Bool?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
//        case transferIndex = "transfer_index"
//        case ownerOf = "owner_of"
//        case blockNumber = "block_number"
//        case blockNumberMinted = "block_number_minted"
//        case tokenHash = "token_hash"
//        case amount
//        case updatedAt = "updated_at"
//        case contractType = "contract_type"
//        case tokenURI = "token_uri"
//        case metadata
//        case lastTokenURISync = "last_token_uri_sync"
//        case lastMetadataSync = "last_metadata_sync"
//        case minterAddress = "minter_address"
//        case normalizedMetadata = "normalized_metadata"
//        case media
//        case possibleSpam = "possible_spam"
//        case verifiedCollection = "verified_collection"
    }
}

// MARK: - Media
//struct Media: Codable {
//    let originalMediaURL: String?
////    let updatedAt, status: String?
//
//    enum CodingKeys: String, CodingKey {
//        case originalMediaURL = "original_media_url"
////        case updatedAt, status
//    }
//}

// MARK: - NormalizedMetadata
struct NormalizedMetadata: Codable {
//    let name, description: String?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
//        case name, description
        case image
    }
    
//    typealias NFTMetadata = [NFTMetadatum]
    
}

struct NFTMetadataRequest: Codable {
    let tokens: [NFTForFetch]?
    let normalizeMetadata, mediaItems: Bool?
    
    enum CodingKeys: String, CodingKey {
        case tokens, normalizeMetadata
        case mediaItems = "media_items"
    }
}
