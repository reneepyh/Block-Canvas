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
        if let fetchedWatchlistItems = WatchlistManager.shared.fetchWatchlistItems() {
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
        watchlistCell.imageView.loadImage(watchlistNFTs[indexPath.row].thumbnailUri)
        watchlistCell.imageView.contentMode = .scaleAspectFill
        
        return watchlistCell
    }
    
    // 指定 item 寬度和數量
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width
        let totalSapcing = CGFloat(4 * 3)
        
        let itemWidth = (maxWidth - totalSapcing)  / 4
        return CGSize(width: itemWidth * 1.3, height: itemWidth * 1.3)
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
        detailVC.indexPath = indexPath
        detailVC.delegate = self
        show(detailVC, sender: nil)
    }
}

extension WatchlistPageViewController: DetailPageViewControllerDelegate {
    func deleteWatchlistItem(at indexPath: IndexPath) {
        WatchlistManager.shared.deleteWatchlistItem(at: indexPath)
        watchlistNFTs.remove(at: indexPath.row)
        watchlistCollectionView.deleteItems(at: [indexPath])
        watchlistCollectionView.reloadData()
    }
}
