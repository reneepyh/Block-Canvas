//
//  DiscoverAPIService.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/7.
//

import Foundation

class DiscoverAPIService {
    static let shared = DiscoverAPIService()
    
    private init() {}
}

extension DiscoverAPIService {
    func getTrending(completion: @escaping (Result<[DiscoverNFT], Error>) -> Void) {
        var trendingNFTs: [DiscoverNFT] = []
        let group = DispatchGroup()
        
        func fetchToken() {
            group.enter()
            let url = URL(string: "https://api.fxhash.xyz/graphql")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let query = """
            {
               randomTopGenerativeToken {
                   author {
                     name
                   }
                   gentkContractAddress
                   issuerContractAddress
                   metadata
                   id
                 }
            }
            """
            
            let json: [String: Any] = ["query": query]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer {
                    group.leave()
                }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let root = try decoder.decode(Root.self, from: data)
                    if trendingNFTs.contains(where: { $0.title == root.data.randomTopGenerativeToken.metadata.name }) {
                        fetchToken()
                        return
                    }
                    
                    let contract = root.data.randomTopGenerativeToken.gentkContractAddress
                    let thumbnailURL = self.generativeLiveDisplayUrl(uri: root.data.randomTopGenerativeToken.metadata.thumbnailUri)
                    let displayURL = self.generativeLiveDisplayUrl(uri: root.data.randomTopGenerativeToken.metadata.displayUri)
                    let authorName = root.data.randomTopGenerativeToken.author?.name ?? " "
                    let title = root.data.randomTopGenerativeToken.metadata.name
                    let description = root.data.randomTopGenerativeToken.metadata.description
                    let id = String(root.data.randomTopGenerativeToken.id)
                    trendingNFTs.append(DiscoverNFT(thumbnailUri: thumbnailURL, displayUri: displayURL, contract: contract, title: title, authorName: authorName, nftDescription: description, id: id))
                } catch {
                    print("Error in JSON decoding.")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
        for _ in 0..<10 {
            fetchToken()
        }
        
        group.notify(queue: .main) {
            completion(.success(trendingNFTs))
        }
    }
    
    func searchNFT(keyword: String, offset: Int, completion: @escaping (Result<[DiscoverNFT], Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Reservoir_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reservoir API Key does not exist."])))
            return
        }
        
        let formattedKeyword = keyword.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "https://api.reservoir.tools/search/collections/v2?name=\(formattedKeyword)&limit=10&offset=\(offset)") {
            print(url)
            var request = URLRequest(url: url)
            request.setValue(key, forHTTPHeaderField: "X-API-KEY")
            request.httpMethod = "GET"
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 6.0
            configuration.timeoutIntervalForResource = 6.0
            
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data."])))
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    var discoverNFTs: [DiscoverNFT] = []
                    for searchResult in searchData.collections ?? [] {
                        let nftDescription = searchResult.slug.map { "https://opensea.io/collection/\($0)" } ?? ""
                        discoverNFTs.append(DiscoverNFT(thumbnailUri: searchResult.image ?? "", displayUri: searchResult.image ?? "", contract: searchResult.contract ?? "", title: searchResult.name, authorName: "", nftDescription: nftDescription, id: ""))
                    }
                    completion(.success(discoverNFTs))
                }
                catch {
                    print("Error in JSON decoding.")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
        }
    }
    
    func getRecommendationFromGPT(userNFTs: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key does not exist."])))
            return
        }
        
        var openAIBody: OpenAIBody?
        
        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
            var request = URLRequest(url: url)
            request.setValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(key)",
                             forHTTPHeaderField: "Authorization")
            if userNFTs.isEmpty {
                openAIBody = OpenAIBody(messages: [
                    ["role": "user", "content": """
               Please suggest art NFT collections. Suggest NFT collections should be on Ethereum blockchain. Please suggest 5 NFT collections. Provide only the collection names in bullet pointsc (not numbered lists) and not any other responses. Please do not mention the artist's name. Please do not include double quotes for the response. Please also do not include symbols such as colon, semicolon or dash.
               """]
                ])
                
            } else {
                var randomNFTs: [String] = []
                randomNFTs.append(userNFTs.randomElement() ?? "")
                randomNFTs.append(userNFTs.randomElement() ?? "")
                randomNFTs.append(userNFTs.randomElement() ?? "")
                print(randomNFTs)
                
                openAIBody = OpenAIBody(messages: [
                    ["role": "user", "content": """
               Generate recommendations for NFT collections similar to the following:
               
               Collection Name: \(randomNFTs)
               Hosted blockchain: Ethereum
               
               Please suggest NFT collections that share similarities with the provided collection. Suggest NFT collections should be on Ethereum blockchain. Please suggest 5 NFT collections. Provide only the collection names in bullet pointsc (not numbered lists) and not any other responses. Please do not mention the artist's name. Please do not include double quotes for the response. Please also do not include symbols such as colon, semicolon or dash.
               """]
                ])
            }
            
            request.httpBody = try? JSONEncoder().encode(openAIBody)
            request.httpMethod = "POST"
            
            if let postData = try? JSONEncoder().encode(openAIBody) {
                if let jsonString = String(data: postData, encoding: .utf8) {
                    print("Request JSON: \(jsonString)")
                }
                request.httpBody = postData
            } else {
                print("Failed to encode the JSON data")
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let data = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                        let recommendedResponse = data.choices?[0].message?.content
                        print("response: \(recommendedResponse)")
                        let recommendedCollections = recommendedResponse?.split(separator: "\n").map { line -> String in
                            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                            if trimmedLine.hasPrefix("-") {
                                let collectionName = String(trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces))
                                return collectionName.replacingOccurrences(of: " ", with: "")
                            } else {
                                return trimmedLine.replacingOccurrences(of: " ", with: "")
                            }
                        }
                        completion(.success(recommendedCollections ?? []))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error."])))
                }
            }.resume()
        }
        else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
        }
    }
    
    func getRecommendedNFTs(collectionName: String, completion: @escaping (Result<[DiscoverNFT], Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Reservoir_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reservoir API Key does not exist."])))
            return
        }
        
        if let url = URL(string: "https://api.reservoir.tools/search/collections/v2?name=\(collectionName)&limit=5") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 4.0
            configuration.timeoutIntervalForResource = 4.0
            
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data."])))
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    var nftDescription = ""
                    var recommendedNFTs: [DiscoverNFT] = []
                    for searchResult in searchData.collections ?? [] {
                        if let slug = searchResult.slug {
                            nftDescription = "https://opensea.io/collection/\(slug)"
                        } else {
                            nftDescription = ""
                        }
                        if let image = searchResult.image, !image.isEmpty {
                            recommendedNFTs.append(DiscoverNFT(thumbnailUri: image, displayUri: image, contract: searchResult.contract ?? "", title: searchResult.name, authorName: "", nftDescription: nftDescription, id: ""))
                        }
                    }
                    completion(.success(recommendedNFTs))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
        }
    }
}

extension DiscoverAPIService {
    private func generativeLiveDisplayUrl(uri: String) -> String {
        let gateway = "https://gateway.fxhash.xyz/ipfs/"
        let startIndex = uri.index(uri.startIndex, offsetBy: 7)
        let newUri = String(uri[startIndex...])
        return gateway + newUri
    }
}
