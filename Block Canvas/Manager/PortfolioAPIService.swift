//
//  PortfolioAPIService.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/23.
//

import Foundation
import Combine

class PortfolioAPIService {
    static let shared = PortfolioAPIService()
    
    private init() {}
    
    func fetchWalletBalance(address: String) -> AnyPublisher<WalletBalance, Error> {
        let urlString: String
        
        if address.hasPrefix("0x") {
            urlString = "https://svc.blockdaemon.com/universal/v1/ethereum/mainnet/account/\(address)"
        } else {
            urlString = "https://svc.blockdaemon.com/universal/v1/tezos/mainnet/account/\(address)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NSError(domain: "ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Bundle.main.object(forInfoDictionaryKey: "Blockdaemon_API_Key") as? String, forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: WalletBalance.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getNFTsByWallet(walletAddress: String, completion: @escaping ([NFTInfoForDisplay]?, Error?) -> Void) {
        guard let apiKey = getAPIKey(for: walletAddress) else {
            completion(nil, NSError(domain: "ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "API Key not found"]))
            return
        }
        
        guard let url = buildAPIURL(for: walletAddress) else {
            completion(nil, NSError(domain: "ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"]))
                return
            }
            
            do {
                let nftInfoForDisplay = try self.handleNFTData(data: data, walletAddress: walletAddress)
                completion(nftInfoForDisplay, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    private func getAPIKey(for walletAddress: String) -> String? {
        let apiKey: String?
        if walletAddress.hasPrefix("0x") == true {
            apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
        } else {
            apiKey = Bundle.main.object(forInfoDictionaryKey: "Rarible_API_Key") as? String
        }
        
        if apiKey == nil || apiKey?.isEmpty == true {
            print("API Key does not exist.")
        }
        
        return apiKey
    }
    
    private func buildAPIURL(for address: String) -> URL? {
        let baseURL: String
        if address.hasPrefix("0x") {
            baseURL = "https://deep-index.moralis.io/api/v2.2/\(address)/nft?chain=eth&format=decimal&exclude_spam=true&normalizeMetadata=true&media_items=true"
        } else {
            let modifiedContract = address.replacingOccurrences(of: "TEZOS:", with: "")
            baseURL = "https://api.rarible.org/v0.1/items/byOwner?owner=TEZOS:\(modifiedContract)"
        }
        
        return URL(string: baseURL)
    }
    
    private func handleNFTData(data: Data, walletAddress: String) throws -> [NFTInfoForDisplay] {
        let decoder = JSONDecoder()
        
        if walletAddress.hasPrefix("0x") {
            let ethNFTData = try decoder.decode(EthNFT.self, from: data)
            return handleEthNFTData(ethNFTData)
        } else {
            let tezosNFTData = try decoder.decode(TezosNFT.self, from: data)
            return handleTezosNFTData(tezosNFTData)
        }
    }
    
    private func handleEthNFTData(_ ethNFTData: EthNFT) -> [NFTInfoForDisplay] {
        var nftInfoForDisplay: [NFTInfoForDisplay] = []
        nftInfoForDisplay = ethNFTData.result.map { ethNFTMetadata in
            return ethNFTMetadata.compactMap { ethNFT in
                if let image = ethNFT.media?.mediaCollection?.high?.url {
                    guard let imageUrl = URL(string: image) else {
                        fatalError("Cannot get the image URL of NFT.")
                    }
                    return NFTInfoForDisplay(url: imageUrl, title: ethNFT.normalizedMetadata?.name ?? "", artist: ethNFT.metadataObject?.createdBy ?? "", description: ethNFT.normalizedMetadata?.description ?? "")
                } else {
                    return nil
                }
            }
        } ?? []
        print(nftInfoForDisplay)
        return nftInfoForDisplay
    }
    
    private func handleTezosNFTData(_ tezosNFTData: TezosNFT) -> [NFTInfoForDisplay] {
        var nftInfoForDisplay: [NFTInfoForDisplay] = []
        nftInfoForDisplay = tezosNFTData.items.map { tezosNFTMetadata in
            return tezosNFTMetadata.compactMap { tezosNFT in
                if let image = tezosNFT.meta?.content?.first?.url {
                    guard let imageUrl = URL(string: image) else {
                        fatalError("Cannot get the image URL of NFT.")
                    }
                    let modifiedContract = tezosNFT.contract?.replacingOccurrences(of: "TEZOS:", with: "")
                    
                    return NFTInfoForDisplay(url: imageUrl, title: tezosNFT.meta?.name ?? "", artist: "", description: tezosNFT.meta?.description ?? "")
                } else {
                    return nil
                }
            }
        } ?? []
        print(nftInfoForDisplay)
        return nftInfoForDisplay
    }
}
