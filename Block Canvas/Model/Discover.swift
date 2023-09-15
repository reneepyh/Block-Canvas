//
//  Discover.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

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
    let tokenContract: String
    let tokenID: String
}

struct NFTMetadatum: Codable {
    let tokenAddress, tokenID, contractType, ownerOf: String?
    let blockNumber, blockNumberMinted: String?
    let normalizedMetadata: NormalizedMetadata?
    let amount, name, symbol, tokenHash: String?
    let lastTokenURISync, lastMetadataSync: String?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
        case contractType = "contract_type"
        case ownerOf = "owner_of"
        case blockNumber = "block_number"
        case blockNumberMinted = "block_number_minted"
        case normalizedMetadata = "normalized_metadata"
        case amount, name, symbol
        case tokenHash = "token_hash"
        case lastTokenURISync = "last_token_uri_sync"
        case lastMetadataSync = "last_metadata_sync"
    }
}

// MARK: - NormalizedMetadata
struct NormalizedMetadata: Codable {
    let name, description: String?
    let image: String?
    let externalLink, animationURL: String?

    enum CodingKeys: String, CodingKey {
        case name, description, image
        case externalLink = "external_link"
        case animationURL = "animation_url"
    }
}

typealias NFTMetadata = [NFTMetadatum]
