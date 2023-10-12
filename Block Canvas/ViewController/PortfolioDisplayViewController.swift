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
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.secondary, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    var nftInfoForDisplay: [NFTInfoForDisplay]?
    
    var walletAddress: String?
    
    private var userNFTs: [String] = []
    
    private let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNFTsByWallet()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavTab()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(16)
        }
    }
    
    private func setupNavTab() {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    // swiftlint: disable function_body_length
    private func getNFTsByWallet() {
        BCProgressHUD.show()
        guard let address = walletAddress else {
            print("No address.")
            BCProgressHUD.showFailure(text: "No address.")
            return
        }
        
        if address.hasPrefix("0x") {
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
                        BCProgressHUD.showFailure(text: "Address error.")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data.")
                        BCProgressHUD.showFailure(text: "No NFT to show.")
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let NFTData = try decoder.decode(EthNFT.self, from: data)
                        self?.nftInfoForDisplay = NFTData.result.map({ ethNFTMetadata in
                            ethNFTMetadata.compactMap { ethNFT in
                                if let image = ethNFT.media?.mediaCollection?.high?.url {
                                    guard let imageUrl = URL(string: image) else {
                                        fatalError("Cannot get image URL of NFT.")
                                    }
                                    return NFTInfoForDisplay(url: imageUrl, title: ethNFT.normalizedMetadata?.name ?? "", artist: ethNFT.metadataObject?.createdBy ?? "", description: ethNFT.normalizedMetadata?.description ?? "", contract: ethNFT.tokenAddress ?? "")
                                } else {
                                    return nil
                                }
                            }
                        })
                        // for you
                        self?.nftInfoForDisplay?.forEach({ nft in
                            self?.userNFTs.append(nft.title)
                        })
                        self?.userDefaults.set(self?.userNFTs, forKey: "userNFTs")
                    }
                    catch {
                        print("Error in JSON decoding.")
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.setupDisplay()
                    }
                    BCProgressHUD.dismiss()
                }
                task.resume()
            }
            else {
                print("Invalid URL.")
                BCProgressHUD.showFailure(text: "Address error.")
            }
        }
        else {
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "Rarible_API_Key") as? String
            
            guard let key = apiKey, !key.isEmpty else {
                print("Rarible API Key does not exist.")
                return
            }
            
            if let url = URL(string: "https://api.rarible.org/v0.1/items/byOwner?owner=TEZOS:\(address)") {
                
                var request = URLRequest(url: url)
                request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
                request.httpMethod = "GET"
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: request) { [weak self] data, response, error in
                    if let error = error {
                        print(error)
                        BCProgressHUD.showFailure(text: "Address error.")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data.")
                        BCProgressHUD.showFailure(text: "No NFT to show.")
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let NFTData = try decoder.decode(TezosNFT.self, from: data)
                        print(NFTData)
                        self?.nftInfoForDisplay = NFTData.items.map({ tezosNFTMetadata in
                            tezosNFTMetadata.compactMap { tezosNFT in
                                if let image = tezosNFT.meta?.content?.first?.url {
                                    guard let imageUrl = URL(string: image) else {
                                        fatalError("Cannot get image URL of NFT.")
                                    }
                                    let modifiedContract = tezosNFT.contract?.replacingOccurrences(of: "TEZOS:", with: "")
                                    return NFTInfoForDisplay(url: imageUrl, title: tezosNFT.meta?.name ?? "", artist: "", description: tezosNFT.meta?.description ?? "", contract: modifiedContract ?? "")
                                } else {
                                    return nil
                                }
                            }
                        })
                        print(self?.nftInfoForDisplay)
                        // for you
                        self?.nftInfoForDisplay?.forEach({ nft in
                            self?.userNFTs.append(nft.title)
                        })
                        self?.userDefaults.set(self?.userNFTs, forKey: "userNFTs")
                    }
                    catch {
                        print("Error in JSON decoding.")
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.setupDisplay()
                    }
                    BCProgressHUD.dismiss()
                }
                task.resume()
            }
            else {
                print("Invalid URL.")
                BCProgressHUD.showFailure(text: "Address error.")
            }
        }
    }
    
    private func setupDisplay() {
        guard let nftInfoForDisplay = nftInfoForDisplay else {
            print("Cannot create imageURLs.")
            BCProgressHUD.showFailure(text: "No NFT to show.")
            return
        }
        
        let hostingController = UIHostingController(rootView: PortfolioDisplay(nfts: nftInfoForDisplay))
        hostingController.rootView.onARButtonTap = { selectedImageURL in
            self.viewInARButtonTapped(with: selectedImageURL)
        }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        let portfolioDisplayView = hostingController.view
        
        guard let portfolioDisplayView = portfolioDisplayView else {
            print("No portfolio display view.")
            return
        }
        
        portfolioDisplayView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
    }
    
    func viewInARButtonTapped(with url: URL) {
        BCProgressHUD.show()
        let arViewController = ARDisplayViewController()
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
            } else if let data = data, let image = UIImage(data: data) {
                arViewController.imageToDisplay = image
                DispatchQueue.main.async {
                    arViewController.modalPresentationStyle = .overFullScreen
                    BCProgressHUD.dismiss()
                    self.present(arViewController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
