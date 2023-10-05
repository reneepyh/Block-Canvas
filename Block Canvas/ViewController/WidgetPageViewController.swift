//
//  WidgetPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/1.
//

import UIKit

class WidgetPageViewController: UIViewController {
    @IBOutlet weak var walletListTableView: UITableView!
    
    var nftInfoForDisplay: [NFTInfoForDisplay]?
    
    private let userDefaults = UserDefaults.standard
    
    private var walletAddress: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupUI()
        fetchWallets()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        self.title = "choose wallet."
        let navigationBar = self.navigationController?.navigationBar
        navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .primary
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondary, NSAttributedString.Key.font: UIFont.main(ofSize: 16)]
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.backButtonTitle = ""
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupTableView() {
        walletListTableView.dataSource = self
        walletListTableView.delegate = self
        walletListTableView.backgroundColor = .primary
        walletListTableView.rowHeight = UITableView.automaticDimension
        walletListTableView.estimatedRowHeight = 200
    }
    
    private func fetchWallets() {
        let savedWallets = UserDefaults.standard.object(forKey: "walletAddress") as? [[String: String]] ?? []
        
        if savedWallets.isEmpty {
            walletAddress = [["address": "0x423cE4833b42b48611C662cFdc70929E3139b009", "name": "Demo Address"]]
        } else {
            walletAddress = savedWallets
        }
    }
    
    private func getNFTsByWallet(address: String) {
        BCProgressHUD.show()
        
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
                    BCProgressHUD.showFailure()
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    BCProgressHUD.showFailure()
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let NFTData = try decoder.decode(EthNFT.self, from: data)
                    print(NFTData)
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
                    
                    let sharedDefaults = UserDefaults(suiteName: "group.CML8K54JBW.reneehsu.Block-Canvas")
                    let encoder = JSONEncoder()
                    if let encodedData = try? encoder.encode(self?.nftInfoForDisplay) {
                        sharedDefaults?.set(encodedData, forKey: "nftInfoForDisplay")
                    }
                    print(sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data)
                    DispatchQueue.main.async {
                        guard
                            let widgetSelectedVC = UIStoryboard.settings.instantiateViewController(
                                withIdentifier: String(describing: WidgetWalletSelectedViewController.self)
                            ) as? WidgetWalletSelectedViewController
                        else {
                            return
                        }
                        widgetSelectedVC.modalPresentationStyle = .overFullScreen
                        self?.navigationController?.pushViewController(widgetSelectedVC, animated: true)
                    }
                }
                catch {
                    print("Error in JSON decoding.")
                }
                BCProgressHUD.dismiss()
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
}

extension WidgetPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        walletAddress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let walletCell = walletListTableView.dequeueReusableCell(withIdentifier: WalletListCell.reuseIdentifier, for: indexPath) as? WalletListCell else {
            fatalError("Cannot create wallet list cell.")
        }
        walletCell.walletImageView.image = UIImage(named: "ethereum")
        let address = walletAddress[indexPath.row]["address"]
        walletCell.addressLabel.text = address
        walletCell.walletNameTextField.text = walletAddress[indexPath.row]["name"]
        walletCell.walletNameTextField.isUserInteractionEnabled = false
        walletCell.balanceLabel.isHidden = true
        walletCell.arrowImageView.isHidden = true
        return walletCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let address = walletAddress[indexPath.row]["address"] else {
            print("Cannot get wallet address.")
            return
        }
        self.getNFTsByWallet(address: address)
    }
}
