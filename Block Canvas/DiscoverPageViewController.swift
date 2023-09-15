//
//  ViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/13.
//

import UIKit
import Apollo

class DiscoverPageViewController: UIViewController {
    
    private let apolloClient = ApolloClient(url: URL(string: "https://api.fxhash.xyz/graphql")!)
    
    private var recommendedCollections: [ArtCollection] = []
    
    private var recommendedContracts: [String] = []
    
    private var recommendedNFTs: [NFTForFetch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getTrending()
        getRecommendationFromGPT()
    }
    
    private func getTrending() {
        apolloClient.fetch(query: GetTrending.GetTrendingQuery()) { result in
            guard let data = try? result.get().data else { return }
            print(data.randomTopGenerativeToken.displayUri)
            print(data.randomTopGenerativeToken.author.name)
            print(data.randomTopGenerativeToken.name)
        }
        
    }
    
    private func getRecommendationFromGPT() {
        //TODO: error handle不遵照格式
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("OpenAI API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
            var request = URLRequest(url: url)
            request.setValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(key)",
                             forHTTPHeaderField: "Authorization")
            let openAIBody = OpenAIBody(messages: [
                ["role": "user", "content": """
       Generate recommendations for NFT collections similar to the following:
       
       Collection Name: The Art of Seasons
       Artist Name: Dirty Robot
       Hosted blockchain: Ethereum
       Collection Contract Address: 0x5bd815fd6c096bab38b4c6553cfce3585194dff9
       
       Please suggest NFT collections that share similarities with the provided collection. Suggest NFT collections should be on Ethereum blockchain. Consider factors such as the artist's style, theme, or genre of artwork. Please suggest 5 NFT collections. Provide only the collection names and artist names in bullet points and not any other responses.
       
       Ensure the recommendations are art NFT collections.
       """]
            ])
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
                        
                        DispatchQueue.main.async {
                            if let response = data.choices?[0].message?.content, let self = self {
                                print(response)
                                let regexPattern = "Collection Name: \"([^\"]+)\"\\s+Artist Name: (\\w+)"
                                
                                do {
                                    let regex = try NSRegularExpression(pattern: regexPattern, options: [])
                                    let nsString = response as NSString
                                    let matches = regex.matches(in: response, options: [], range: NSRange(location: 0, length: nsString.length))
                                    
                                    for match in matches {
                                        if let collectionRange = Range(match.range(at: 1), in: response),
                                           let artistRange = Range(match.range(at: 2), in: response) {
                                            
                                            let collectionName = String(response[collectionRange])
                                            let trimmedCollection = String(collectionName.filter { !" ".contains($0) })
                                            self.recommendedCollections.append(ArtCollection(collectionName: trimmedCollection))
                                        }
                                    }
                                    print(self.recommendedCollections)
                                } catch let error {
                                    print("Failed to create regex: \(error.localizedDescription)")
                                }
                                
                                // Use extracted data
                                for collection in self.recommendedCollections {
                                    self.getRecommendedContracts(collectionName: collection.collectionName)
                                }
                            }
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }
                if let error = error {
                    print("Error when post request to GPT API:\(error)")
                    
                }
            }.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getRecommendedContracts(collectionName: String) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NFT_GO_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("NFTGo API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://data-api.nftgo.io/eth/v1/collection/name/\(collectionName)") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "X-API-Key")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let data = try decoder.decode(SearchedNFT.self, from: data)
                    
                    DispatchQueue.main.async { [weak self] in
                        for collection in data.collections ?? [] {
                            if data.total != 0 {
                                self?.recommendedContracts.append(collection.contracts?[0] ?? "")
                            }
                        }
                    }
                    for contract in self.recommendedContracts {
                        self.getNFTByContract(address: contract)
                    }
                    print(self.recommendedContracts)
                }
                catch {
                    print("Error in JSON decoding.")
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getNFTByContract(address: String) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Moralis API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/nft/\(address)?chain=eth&format=decimal&limit=1") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "X-API-Key")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let NFTData = try decoder.decode(GetNFTByContract.self, from: data)
                    DispatchQueue.main.async { [weak self] in
                        for NFT in NFTData.result ?? [] {
                            self?.recommendedNFTs.append(NFTForFetch(tokenContract: NFT.tokenAddress ?? "", tokenID: NFT.tokenID ?? ""))
                        }
                    }
                    print(self.recommendedNFTs)
                }
                catch {
                    print("Error in JSON decoding.")
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
//    private func getNFTMetadata(tokenAddress: String, tokenID: String) {
//        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
//
//        guard let key = apiKey, !key.isEmpty else {
//            print("Moralis API key does not exist.")
//            return
//        }
//
//        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/nft/getMultipleNFTs") {
//            var request = URLRequest(url: url)
//            request.setValue("application/json",
//                             forHTTPHeaderField: "Accept")
//            request.setValue(key,
//                             forHTTPHeaderField: "X-API-Key")
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            let requestBody = NFTMetadataRequest(tokens: <#T##[Token]?#>, normalizeMetadata: <#T##Bool?#>, mediaItems: <#T##Bool?#>)
//            request.httpBody = try? JSONEncoder().encode(requestBody)
//            request.httpMethod = "POST"
//
//            if let postData = try? JSONEncoder().encode(requestBody) {
//                if let jsonString = String(data: postData, encoding: .utf8) {
//                    print("Request JSON: \(jsonString)")
//                }
//                request.httpBody = postData
//            } else {
//                print("Failed to encode the JSON data")
//            }
//
//            let session = URLSession.shared
//
//            let task = session.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print(error)
//                    return
//                }
//
//                guard let data = data else {
//                    print("No data.")
//                    return
//                }
//
//                let decoder = JSONDecoder()
//
//                do {
//                    let NFTData = try decoder.decode(GetNFTByContract.self, from: data)
//                    DispatchQueue.main.async { [weak self] in
//                        for NFT in NFTData.result ?? [] {
//                            self?.recommendedNFTs.append(NFTForFetch(tokenContract: NFT.tokenAddress ?? "", tokenID: NFT.tokenID ?? ""))
//                        }
//                    }
//                    print(self.recommendedNFTs)
//                }
//                catch {
//                    print("Error in JSON decoding.")
//                }
//            }
//            task.resume()
//        }
//        else {
//            print("Invalid URL.")
//        }
//    }
}

