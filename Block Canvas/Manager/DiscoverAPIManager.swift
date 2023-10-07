//
//  DiscoverAPIManager.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/7.
//

import Foundation

protocol DiscoverAPIManagerDelegate {
    func didFetchData<T: Decodable>(_ data: T, for apiType: DiscoverAPIManager.APIType)
    func didFailWithError(_ error: Error, for apiType: DiscoverAPIManager.APIType)
}

class DiscoverAPIManager {
    enum APIType {
        case getTrending
        case searchNFT
        case getRecommendedNFTs
    }
    
    enum APIError: Error {
        case noData
    }
    
    var delegate: DiscoverAPIManagerDelegate?
    
    func fetchData<T: Decodable>(for apiType: APIType, decodingType: T.Type) {
        
        var urlString: String
        var apiKey: String
        
        switch apiType {
            case .getTrending:
                urlString = "https://api.fxhash.xyz/graphql"
                apiKey = "YOUR_API_KEY_FOR_GETTRENDING"
            case .searchNFT:
                urlString = "https://api.reservoir.tools/search/collections/v2"
                apiKey = "YOUR_API_KEY_FOR_SEARCHNFT"
            case .getRecommendedNFTs:
                urlString = "YOUR_ENDPOINT_FOR_GETRECOMMENDEDNFTS"
                apiKey = "YOUR_API_KEY_FOR_GETRECOMMENDEDNFTS"
        }
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    self?.delegate?.didFailWithError(error, for: apiType)
                    return
                }
                
                guard let data = data else {
                    self?.delegate?.didFailWithError(DiscoverAPIManager.APIError.noData, for: apiType)
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let decodedData = try decoder.decode(decodingType, from: data)
                    self?.delegate?.didFetchData(decodedData, for: apiType)
                }
                catch {
                    self?.delegate?.didFailWithError(error, for: apiType)
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
}

