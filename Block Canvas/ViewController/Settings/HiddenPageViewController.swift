//
//  HiddenPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/8.
//

import UIKit

class HiddenPageViewController: UIViewController {
    @IBOutlet weak var hiddenCollectionView: UICollectionView!
    
    private var hiddenNFTs: [NFTInfoForDisplay] = []
    
    private let emptyView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "You haven't hidden any artworks."
        label.textColor = .secondaryBlur
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHiddenNFTs()
        setupNavTab()
    }
}

// MARK: - UI Functions
extension HiddenPageViewController {
    private func setupUI() {
        view.backgroundColor = .primary
        self.title = "hidden."
        hiddenCollectionView.dataSource = self
        hiddenCollectionView.delegate = self
        hiddenCollectionView.backgroundColor = .primary
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
    }
    
    private func setupNavTab() {
        let navigationExtendHeight: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        navigationController?.additionalSafeAreaInsets = navigationExtendHeight
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - Fetch Hidden NFTs
extension HiddenPageViewController {
    private func fetchHiddenNFTs() {
        if let fetchedHiddenItems = HiddenManager.shared.fetchHiddenNFTItems() {
            hiddenNFTs = fetchedHiddenItems.map({ managedObject in
                guard let displayURL = URL(string: managedObject.value(forKey: "displayUri") as? String ?? "") else {
                    fatalError("Cannot create display URL.")
                }
                return NFTInfoForDisplay(url: displayURL, title: managedObject.value(forKey: "title") as? String ?? "", artist: managedObject.value(forKey: "artist") as? String ?? "", description: managedObject.value(forKey: "nftDescription") as? String ?? "")
            })
            emptyView.isHidden = !hiddenNFTs.isEmpty
            hiddenCollectionView.reloadData()
        }
    }
}

// MARK: - Collection View
extension HiddenPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hiddenNFTs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let watchlistCell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as? WatchlistCell else {
            fatalError("Cell cannot be created")
        }
        watchlistCell.imageView.loadImage(hiddenNFTs[indexPath.row].url.absoluteString, placeHolder: UIImage(named: "placeholder"))
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
        HiddenManager.shared.deleteHiddenNFTItem(with: hiddenNFTs[indexPath.row].url.absoluteString)
        hiddenNFTs.remove(at: indexPath.row)
        hiddenCollectionView.deleteItems(at: [indexPath])
        emptyView.isHidden = !hiddenNFTs.isEmpty
    }
}
