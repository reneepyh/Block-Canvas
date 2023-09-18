//
//  PortfolioDisplayViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import SwiftUI
import SnapKit
import Kingfisher

class PortfolioDisplayViewController: UIViewController {
    
    var NFTs: EthNFT?
    
    var nftInfoForDisplay: [NFTInfoForDisplay]?
    
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
        
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Moralis API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/\(address)/nft?chain=eth&format=decimal&exclude_spam=true&normalizeMetadata=true&media_items=true") {
            
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
                    self?.nftInfoForDisplay = NFTData.result.map({ ethNFTMetadata in
                        ethNFTMetadata.compactMap { ethNFT in
                            if let image = ethNFT.media?.mediaCollection?.high?.url {
                                guard let imageUrl = URL(string: ethNFT.media?.mediaCollection?.high?.url ?? "") else {
                                    fatalError("Cannot get image URL of NFT.")
                                }
                                return NFTInfoForDisplay(url: imageUrl, title: ethNFT.normalizedMetadata?.name ?? "", artist: ethNFT.metadataObject?.createdBy ?? "", description: ethNFT.normalizedMetadata?.description ?? "", contract: ethNFT.tokenAddress ?? "")
                            } else {
                                return nil
                            }
                        }
                    })
                    print(self?.nftInfoForDisplay)
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
        guard let nftInfoForDisplay = nftInfoForDisplay else {
            print("Cannot create imageURLs.")
            return
        }
        
        let hostingController = UIHostingController(rootView: PortfolioDisplay(nftInfoForDisplay: nftInfoForDisplay, onARButtonTap: { selectedImageURL in
            self.viewInARButtonTapped(with: selectedImageURL)
        }))
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        let portfolioDisplayView = hostingController.view
        
        guard let portfolioDisplayView = portfolioDisplayView else {
            print("No portfolio display view.")
            return
        }
        
        portfolioDisplayView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
    }
    
    func viewInARButtonTapped(with url: URL) {
        let arViewController = ARDisplayViewController()
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
            } else if let data = data, let image = UIImage(data: data) {
                arViewController.imageToDisplay = image
                DispatchQueue.main.async {
                    arViewController.modalPresentationStyle = .overFullScreen
                    self.present(arViewController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
        print(url)
    }
}
