//
//  WatchlistPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/21.
//

import UIKit

class WatchlistPageViewController: UIViewController {
    @IBOutlet weak var watchlistCollectionView: UICollectionView!
    
    private var watchlistNFTs: [DiscoverNFT] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        watchlistCollectionView.dataSource = self
        watchlistCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchWatchlist()
    }
    
    private func fetchWatchlist() {
        if let fetchedWatchlistItems = WatchlistManager.shared.fetchCartProduct() {
            watchlistNFTs = fetchedWatchlistItems.map({ managedObject in
                return DiscoverNFT(thumbnailUri: managedObject.value(forKey: "thumbnailUri") as? String ?? "", displayUri: managedObject.value(forKey: "displayUri") as? String ?? "", contract: managedObject.value(forKey: "contract") as? String ?? "", title: managedObject.value(forKey: "title") as? String, authorName: managedObject.value(forKey: "authorName") as? String, nftDescription: managedObject.value(forKey: "nftDescription") as? String)
            })
            watchlistCollectionView.reloadData()
        }
    }
}

extension WatchlistPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        watchlistNFTs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let watchlistCell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as? WatchlistCell else {
            fatalError("Cell cannot be created")
        }
        watchlistCell.imageView.loadImage(watchlistNFTs[indexPath.row].displayUri)
        
        return watchlistCell
    }
    
    // 指定 item 寬度和數量
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 12 * 2
        let totalSapcing = CGFloat(5 * 2)
        
        let itemWidth = (maxWidth - totalSapcing) / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let detailVC = UIStoryboard.discover.instantiateViewController(
                withIdentifier: String(describing: DetailPageViewController.self)
            ) as? DetailPageViewController
        else {
            return
        }
        detailVC.discoverNFTMetadata = watchlistNFTs[indexPath.row]
        show(detailVC, sender: nil)
    }
}
