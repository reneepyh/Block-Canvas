//
//  CryptoAPIService.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/15.
//

import Foundation

enum CryptoType: String {
    case ETH = "ETHUSDT"
    case XTZ = "XTZUSDT"
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
    private func makeBinanceRequest(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let key = binanceAPIKey, !key.isEmpty else {
            print("API key does not exist.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key does not exist."])))
            return
        }
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue(key, forHTTPHeaderField: "X-MBX-APIKEY")
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
        let urlString = "https://api1.binance.com/api/v3/ticker/price?symbol=\(crypto.rawValue)"
        
        makeBinanceRequest(urlString: urlString) { result in
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
    
    func getPriceChange(for crypto: CryptoType, completion: @escaping (Result<Double, Error>) -> Void) {
        let endpoint = "https://api1.binance.com/api/v3/ticker/24hr?symbol=\(crypto.rawValue)"
        
        makeBinanceRequest(urlString: endpoint) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                
                do {
                    let priceChangeData = try decoder.decode(CryptoPriceChange.self, from: data)
                    let doubledPriceChange = Double(priceChangeData.priceChangePercent)
                    let floored = floor((doubledPriceChange ?? 0) * 100) / 100
                    completion(.success(floored))
                } catch {
                    print("Error in JSON decoding.")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getGasFee(completion: @escaping (Result<String, Error>) -> Void) {
            guard let apiKey = etherscanAPIKey, !apiKey.isEmpty else {
                print("Etherscan API Key does not exist.")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Etherscan API Key does not exist."])))
                return
            }
            
            let urlString = "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=\(apiKey)"
            
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
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
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let ethGasFee = try decoder.decode(EthGasFee.self, from: data)
                        let gasFee = "\(ethGasFee.result?.proposeGasPrice ?? "") gwei"
                        completion(.success(gasFee))
                    } catch {
                        print("Error in JSON decoding.")
                        completion(.failure(error))
                    }
                }
                task.resume()
            } else {
                print("Invalid URL.")
            }
        }
    
    func getHistoryPrice(for crypto: CryptoType, completion: @escaping (Result<[HistoryPriceData], Error>) -> Void) {
            BCProgressHUD.show()
            
            var urlString: String
            
            switch crypto {
            case .ETH:
                urlString = "https://api.coincap.io/v2/assets/ethereum/history?interval=m1"
            case .XTZ:
                urlString = "https://api.coincap.io/v2/assets/tezos/history?interval=m1"
            }
            
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.setValue("deflate", forHTTPHeaderField: "Accept-Encoding")
                request.httpMethod = "GET"
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: request) { [weak self] data, response, error in
                    if let error = error {
                        print(error)
                        BCProgressHUD.showFailure()
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        print("No data.")
                        BCProgressHUD.showFailure()
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data."])))
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let priceHistory = try decoder.decode(CryptoHistoryPrice.self, from: data)
                        var historyPriceData: [HistoryPriceData] = []
                        for priceData in priceHistory.data {
                            let unixTimestampSeconds = Double(priceData.time) / 1000.0
                            let date = Date(timeIntervalSince1970: unixTimestampSeconds)
                            historyPriceData.append(HistoryPriceData(price: Double(priceData.priceUsd) ?? 0, time: date))
                        }
                        completion(.success(historyPriceData))
                    } catch {
                        print("Error in JSON decoding.")
                        completion(.failure(error))
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        BCProgressHUD.dismiss()
                    }
                }
                task.resume()
            } else {
                print("Invalid URL.")
                BCProgressHUD.showFailure()
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            }
        }
}
