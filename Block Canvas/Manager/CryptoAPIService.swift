//
//  CryptoAPIService.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/15.
//

import Foundation

enum CryptoType: String {
    case ETH = "ETHUSDT"
    case XYZ = "XTZUSDT"
}

class CryptoAPIService {
    static let shared = CryptoAPIService()
    
    private init() {}
    
    private let binanceAPIKey: String? = {
        return Bundle.main.object(forInfoDictionaryKey: "Binance_API_Key") as? String
    }()
    
    private let etherscanAPIKey: String? = {
        return Bundle.main.object(forInfoDictionaryKey: "Etherscan_API_Key") as? String
    }()
}

extension CryptoAPIService {
    private func makeBinanceRequest(urlString: String, apiKey: String?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let key = apiKey, !key.isEmpty else {
            print("API key does not exist.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key does not exist."])))
            return
        }
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data."])))
                    return
                }
                
                completion(.success(data))
            }
            task.resume()
        } else {
            print("Invalid URL.")
        }
    }
    
    func getCurrentPrice(for crypto: CryptoType, completion: @escaping (Result<Double, Error>) -> Void) {
        let apiKey = binanceAPIKey
        let urlString = "https://api1.binance.com/api/v3/ticker/price?symbol=\(crypto.rawValue)"
        
        makeBinanceRequest(urlString: urlString, apiKey: apiKey) { result in
            switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    
                    do {
                        let currentPriceData = try decoder.decode(CryptoCurrentPriceData.self, from: data)
                        let doubledCurrentPrice = Double(currentPriceData.price)
                        completion(.success(doubledCurrentPrice ?? 0))
                    } catch {
                        print("Error in JSON decoding.")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
