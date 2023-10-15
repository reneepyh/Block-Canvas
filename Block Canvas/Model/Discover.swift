//
//  Discover.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

struct DiscoverNFT {
    let thumbnailUri: String
    let displayUri: String
    let contract: String
    let title: String?
    let authorName: String?
    let nftDescription: String?
    let id: String
}

struct Root: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let randomTopGenerativeToken: RandomTopGenerativeToken
}

struct RandomTopGenerativeToken: Codable {
    let author: Author?
    let gentkContractAddress, issuerContractAddress: String
    let metadata: TrendingNFTMetadata
    let id: Int
}

struct Author: Codable {
    let name: String?
}

struct TrendingNFTMetadata: Codable {
    let artifactUri: String
    let childrenDescription: String
    let description, displayUri, generativeUri, name: String
    let thumbnailUri: String
}

struct SearchNFT: Codable {
    let collections: [SearchCollection]?
}

struct SearchCollection: Codable {
    let collectionID, name, slug, contract: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case collectionID = "collectionId"
        case name, slug, contract, image
    }
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
