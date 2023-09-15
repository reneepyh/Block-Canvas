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
        
//        if let layout = portfolioCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumInteritemSpacing = 8 // or whatever you need
//            layout.minimumLineSpacing = 8 // or whatever you need
//            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        }
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
        
        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/\(address)/nft?chain=eth&format=decimal&exclude_spam=true&normalizeMetadata=false&media_items=true") {
            
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
        return NFTs?.result?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let portfolioCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: PortfolioCollectionCell.reuseIdentifier, for: indexPath) as? PortfolioCollectionCell else {
            fatalError("Cell cannot be created")
        }
        portfolioCollectionCell.nftImageView.loadImage(NFTs?.result?[indexPath.row].media?.mediaCollection?.medium?.url)
        
        return portfolioCollectionCell
    }
    
    // 指定 item 寬度和數量
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 4 * 2  // padding from both sides
        let itemSpacing: CGFloat = 2  // item spacing
        let itemsPerRow: CGFloat = 2  // number of items in a row
        
        let availableWidth = UIScreen.main.bounds.width - padding - (itemSpacing * (itemsPerRow - 1))
        let itemWidth = availableWidth / itemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as? DetailPageViewController
            detailVC?.NFTMetadata = sender as? EthNFTResult
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let NFT = NFTs?.result?[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: NFT)
    }
}

