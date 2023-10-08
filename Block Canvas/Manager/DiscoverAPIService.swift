//
//  DiscoverAPIService.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/7.
//

import Foundation

class DiscoverAPIService {
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
                    trendingNFTs.append(DiscoverNFT(thumbnailUri: thumbnailURL, displayUri: displayURL, contract: contract, title: title, authorName: authorName, nftDescription: description))
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
    
    func searchNFT(keyword: String, completion: @escaping (Result<[DiscoverNFT], Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Reservoir_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reservoir API Key does not exist."])))
            return
        }
        
        let formattedKeyword = keyword.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "https://api.reservoir.tools/search/collections/v2?name=\(formattedKeyword)&limit=10") {
            
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
                        discoverNFTs.append(DiscoverNFT(thumbnailUri: searchResult.image ?? "", displayUri: searchResult.image ?? "", contract: searchResult.contract ?? "", title: searchResult.name, authorName: "", nftDescription: nftDescription))
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
}

extension DiscoverAPIService {
    private func generativeLiveDisplayUrl(uri: String) -> String {
        let gateway = "https://gateway.fxhash.xyz/ipfs/"
        let startIndex = uri.index(uri.startIndex, offsetBy: 7)
        let newUri = String(uri[startIndex...])
        return gateway + newUri
    }
}