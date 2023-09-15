//
//  PortfolioPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit

class PortfolioPageViewController: UIViewController {
    
    var NFTs: EthNFT?
    
    var ethAddress: String?
    
    @IBOutlet weak var portfolioCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Portfolio\(ethAddress)")
        getEthNFTsByWallet()
        
        portfolioCollectionView.dataSource = self
        portfolioCollectionView.delegate = self
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
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.portfolioCollectionView.reloadData()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
        
    }
}

extension PortfolioPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NFTs?.assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let portfolioCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: PortfolioCollectionCell.reuseIdentifier, for: indexPath) as? PortfolioCollectionCell else {
            fatalError("Cell cannot be created")
        }
        portfolioCollectionCell.nftImageView.loadImage(NFTs?.assets?[indexPath.row].nft?.image)
        
        return portfolioCollectionCell
    }
    
    // 指定 item 寬度和數量
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width
        let totalSapcing = CGFloat(6 * 2)
        
        let itemWidth = (maxWidth - totalSapcing) / 2
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as? DetailPageViewController
            detailVC?.NFTMetadata = sender as? EthNFTMetadata
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let NFT = NFTs?.assets?[indexPath.row].nft
        performSegue(withIdentifier: "showDetail", sender: NFT)
    }
}

