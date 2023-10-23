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
}

// MARK: - UI Functions
extension PortfolioDisplayViewController {
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
    
    private func setupDisplay() {
        guard let nftInfoForDisplay = nftInfoForDisplay else {
            print("Cannot create imageURLs.")
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

// MARK: - API Functions
extension PortfolioDisplayViewController {
    private func getNFTsByWallet() {
        BCProgressHUD.show()
        
        guard let address = walletAddress else {
            handleFailure(message: "No address.")
            return
        }
        
        let apiKey = getAPIKey()
        
        guard let url = buildAPIURL(for: address) else {
            handleFailure(message: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.handleFailure(message: error.localizedDescription)
                return
            }
            
            guard let data = data else {
                self?.handleFailure(message: "No data.")
                return
            }
            
            self?.handleNFTData(data: data)
        }
        task.resume()
    }
    
    private func handleFailure(message: String) {
        print(message)
        BCProgressHUD.showFailure(text: "Address error.")
    }
    
    private func getAPIKey() -> String? {
        let apiKey: String?
        if walletAddress?.hasPrefix("0x") == true {
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
    
    private func handleNFTData(data: Data) {
        let decoder = JSONDecoder()
        
        do {
            if walletAddress?.hasPrefix("0x") == true {
                let ethNFTData = try decoder.decode(EthNFT.self, from: data)
                self.handleEthNFTData(ethNFTData)
            } else {
                let tezosNFTData = try decoder.decode(TezosNFT.self, from: data)
                self.handleTezosNFTData(tezosNFTData)
            }
        } catch {
            print("Error in JSON decoding.")
            BCProgressHUD.dismiss()
        }
    }
    
    private func handleEthNFTData(_ ethNFTData: EthNFT) {
        self.nftInfoForDisplay = ethNFTData.result.map { ethNFTMetadata in
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
        }
        print(self.nftInfoForDisplay)
        self.updateUserNFTs()
        DispatchQueue.main.async { [weak self] in
            self?.setupDisplay()
        }
        BCProgressHUD.dismiss()
    }
    
    private func handleTezosNFTData(_ tezosNFTData: TezosNFT) {
        self.nftInfoForDisplay = tezosNFTData.items.map { tezosNFTMetadata in
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
        }
        print(self.nftInfoForDisplay)
        self.updateUserNFTs()
        DispatchQueue.main.async { [weak self] in
            self?.setupDisplay()
        }
        BCProgressHUD.dismiss()
    }
    
    private func updateUserNFTs() {
        self.userNFTs = self.nftInfoForDisplay?.map { $0.title } ?? []
        self.userDefaults.set(self.userNFTs, forKey: "userNFTs")
    }
}
