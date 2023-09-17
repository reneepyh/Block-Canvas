//
//  PortfolioDisplayViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import SwiftUI
import SnapKit

class PortfolioDisplayViewController: UIViewController {
    
    var NFTs: EthNFT?
    
    var imageURLs: [URL]?
    
    var ethAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        getEthNFTsByWallet()
    }
    
    private func getEthNFTsByWallet() {
        guard let address = ethAddress else {
            print("No address.")
            return
        }
        
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NFT_GO_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("NFTGO API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://data-api.nftgo.io/eth/v1/address/portfolio/collection?address=\(address)&offset=0&limit=50") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
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
                    let NFTData = try decoder.decode(EthNFT.self, from: data)
                    print(NFTData)
                    self?.NFTs = NFTData
                    self?.imageURLs = NFTData.assets.map({ assets in
                        assets.map { asset in
//                            guard let imageURL = asset.nft?.image else {
//                                print("Cannot create image URL.")
//                                return
//                            }
                            URL(string: (asset.nft?.image) ?? "")!
                        }
                    })
                    print(self?.imageURLs)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.setupDisplay()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
        
    }

    private func setupDisplay() {
        guard let imageURLs = imageURLs else {
            print("Cannot create imageURLs.")
            return
        }
        
        let hostingController = UIHostingController(rootView: PortfolioDisplay(imageUrls: imageURLs))
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        let portfolioDisplayView = hostingController.view
        
        guard let portfolioDisplayView = portfolioDisplayView else {
            print("No portfolio display view.")
            return
        }
        
        portfolioDisplayView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(230)
        }
        
        hostingController.didMove(toParent: self)
    }
}
