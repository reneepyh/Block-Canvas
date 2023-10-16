//
//  DiscoverPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/13.
//

import UIKit

class DiscoverPageViewController: UIViewController {
    @IBOutlet weak var discoverCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var underlineView: UIView!
    
    @IBOutlet weak var underlineViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var underlineViewCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var underlineViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trendingButton: UIButton!
    
    @IBOutlet weak var forYouButton: UIButton!
    
    @IBOutlet weak var nftSearchBar: UISearchBar!
    
    private var selectedPage: Int = 0
    
    private let userDefaults = UserDefaults.standard
    
    private var userNFTs: [String] = []
    
    private var trendingNFTs: [DiscoverNFT] = []
    
    private var searchedNFTs: [DiscoverNFT] = []
    
    private var isSearching: Bool = false
    
    private var currentOffset: Int = 0
    
    private var recommendedCollections: [String] = []
    
    private var recommendedNFTs: [DiscoverNFT] = []
    
    private var recommendationCache: [DiscoverNFT]?
    
    private let apiService = DiscoverAPIService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupButtonTag()
        setupUI()
        getTrending()
        fetchRecommendationInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavTab()
    }
    
    private func setupCollectionView() {
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        discoverCollectionView.backgroundColor = .primary
        
        let layout = WaterFallFlowLayout()
        layout.delegate = self
        layout.cols = 2
        discoverCollectionView.collectionViewLayout = layout
        
        discoverCollectionView.addRefreshHeader(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            
            hideHeaderLoader()
            
            if self.selectedPage == 0 {
                self.getTrending()
            } else if self.selectedPage == 1 {
                BCProgressHUD.show(text: "AI calculating...")
                self.fetchRecommendationData()
            }
        })
        
        discoverCollectionView.addRefreshFooter(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            
            hideFooterLoader()
            
            if self.isSearching == true {
                guard let keyword = self.nftSearchBar.text else {
                    return
                }
                self.apiService.searchNFT(keyword: keyword, offset: self.currentOffset) { result in
                    switch result {
                        case .success(let newNFTs):
                            self.searchedNFTs.append(contentsOf: newNFTs)
                            DispatchQueue.main.async { [weak self] in
                                if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                                    layout.clearCache()
                                }
                                self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
                                self?.discoverCollectionView.reloadData()
                            }
                            self.currentOffset += newNFTs.count
                            if newNFTs.count < 10 {
                                self.discoverCollectionView.endWithNoMoreData()
                            } else {
                                self.discoverCollectionView.endFooterRefreshing()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                            self.discoverCollectionView.endFooterRefreshing()
                    }
                }
            }
        })
    }
    
    private func hideHeaderLoader() {
        if self.isSearching == true {
            self.discoverCollectionView.isHeaderHidden = true
        } else {
            self.discoverCollectionView.isHeaderHidden = false
        }
    }
    
    private func hideFooterLoader() {
        if self.isSearching == true {
            self.discoverCollectionView.isFooterHidden = false
        } else {
            self.discoverCollectionView.isFooterHidden = true
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        underlineView.backgroundColor = .secondary
        trendingButton.tintColor = .secondary
        forYouButton.tintColor = .secondaryBlur
        nftSearchBar.searchTextField.backgroundColor = .tertiary
        nftSearchBar.searchTextField.placeholder = "Find Ethereum NFTs"
        nftSearchBar.searchTextField.textColor = .primary
        nftSearchBar.searchTextField.clearButtonMode = .unlessEditing
        nftSearchBar.searchTextField.autocapitalizationType = .none
        nftSearchBar.searchTextField.autocorrectionType = .no
        nftSearchBar.delegate = self
        nftSearchBar.inputAccessoryView = createCancelToolbar()
    }
    
    private func setupNavTab() {
        let navigationExtendHeight: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        navigationController?.additionalSafeAreaInsets = navigationExtendHeight
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func getTrending() {
        trendingNFTs.removeAll()
        searchedNFTs.removeAll()
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        BCProgressHUD.show()
        
        apiService.getTrending { [weak self] result in
            switch result {
                case .success(let fetchedTrendingNFTs):
                    self?.trendingNFTs = fetchedTrendingNFTs
                    self?.discoverCollectionView.reloadData()
                    self?.discoverCollectionView.endHeaderRefreshing()
                    BCProgressHUD.dismiss()
                case .failure(let error):
                    print("Error: \(error)")
                    BCProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchRecommendationInBackground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchRecommendationData(isBackground: true)
        }
    }
    
    private func searchNFT(keyword: String) {
        BCProgressHUD.show(text: "Searching")
        apiService.searchNFT(keyword: keyword, offset: currentOffset) { [weak self] result in
            switch result {
                case .success(let nfts):
                    self?.searchedNFTs = nfts
                    if nfts.count == 0 {
                        BCProgressHUD.showFailure(text: "No result.")
                    } else {
                        self?.currentOffset += 10
                        DispatchQueue.main.async {
                            self?.discoverCollectionView.reloadData()
                        }
                        BCProgressHUD.dismiss()
                    }
                case .failure(let error):
                    if (error as NSError).code == NSURLErrorTimedOut {
                        BCProgressHUD.showFailure(text: "Internet error. Please try again.")
                    } else {
                        BCProgressHUD.showFailure(text: "No result.")
                    }
            }
        }
    }
    
    private func fetchRecommendationData(isBackground: Bool = false) {
        findUserNFTs()
        searchedNFTs.removeAll()
        recommendedNFTs.removeAll()
        
        apiService.getRecommendationFromGPT(userNFTs: userNFTs) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let recommendedCollections):
                    self.recommendedCollections = recommendedCollections
                    print(recommendedCollections)
                    
                    let group = DispatchGroup()
                    
                    for collection in self.recommendedCollections {
                        group.enter()
                        self.getRecommendedNFTs(collectionName: collection) {
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        if self?.recommendedNFTs.count == 0 {
                            BCProgressHUD.showFailure(text: "Internet error. Please try again.")
                        } else {
                            self?.recommendationCache = self?.recommendedNFTs
                            if !isBackground {
                                self?.updateRecommendationUI()
                            }
                        }
                    }
                case .failure(let error):
                    print("Error fetching recommendation: \(error.localizedDescription)")
                    BCProgressHUD.showFailure(text: "Internet error. Please try again.")
            }
        }
    }
    
    private func updateRecommendationUI() {
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
            self?.discoverCollectionView.endHeaderRefreshing()
            BCProgressHUD.dismiss()
        }
    }
    
    private func getRecommendedNFTs(collectionName: String, completion: @escaping () -> Void) {
        apiService.getRecommendedNFTs(collectionName: collectionName) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let recommendedNFTs):
                    self.recommendedNFTs.append(contentsOf: recommendedNFTs)
                case.failure(let error):
                    print("Error fetching recommended NFTs: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    private func findUserNFTs() {
        userNFTs = userDefaults.object(forKey: "userNFTs") as? [String] ?? []
    }
}

extension DiscoverPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, WaterFallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return searchedNFTs.count
        } else {
            if selectedPage == 0 {
                return trendingNFTs.count
            } else {
                return recommendedNFTs.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let discoverCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCollectionCell.reuseIdentifier, for: indexPath) as? DiscoverCollectionCell else {
            fatalError("Cell cannot be created")
        }
        if isSearching {
            discoverCollectionCell.imageView.loadImage(searchedNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(named: "placeholder"))
            discoverCollectionCell.titleLabel.text = searchedNFTs[indexPath.row].title
        } else if selectedPage == 0 {
            discoverCollectionCell.imageView.loadImage(trendingNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(named: "placeholder"))
            discoverCollectionCell.titleLabel.text = trendingNFTs[indexPath.row].title
        } else {
            discoverCollectionCell.imageView.loadImage(recommendedNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(named: "placeholder"))
            discoverCollectionCell.titleLabel.text = recommendedNFTs[indexPath.row].title
        }
        
        return discoverCollectionCell
    }
    
    func waterFlowLayout(_ waterFlowLayout: WaterFallFlowLayout, itemHeight indexPath: IndexPath) -> CGFloat {
        return CGFloat.random(in: 220...380)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let detailVC = UIStoryboard.discover.instantiateViewController(
                withIdentifier: String(describing: DetailPageViewController.self)
            ) as? DetailPageViewController
        else {
            return
        }
        if isSearching {
            detailVC.discoverNFTMetadata = searchedNFTs[indexPath.row]
            detailVC.indexPath = indexPath
        } else if selectedPage == 0 {
            detailVC.discoverNFTMetadata = trendingNFTs[indexPath.row]
            detailVC.indexPath = indexPath
        } else {
            detailVC.discoverNFTMetadata = recommendedNFTs[indexPath.row]
            detailVC.indexPath = indexPath
        }
        show(detailVC, sender: nil)
    }
    
}

extension DiscoverPageViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedNFTs.removeAll()
        self.currentOffset = 0
        self.discoverCollectionView.resetNoMoreData()
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        
        if let searchText = nftSearchBar.text, searchText != "" {
            isSearching = true
            hideHeaderLoader()
            hideFooterLoader()
            searchNFT(keyword: searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            hideHeaderLoader()
            hideFooterLoader()
            searchedNFTs.removeAll()
            DispatchQueue.main.async { [weak self] in
                if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                    layout.clearCache()
                }
                self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
                self?.discoverCollectionView.reloadData()
            }
        }
    }
    
    func createCancelToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacerButton, cancelButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc func cancelButtonTapped() {
        nftSearchBar.resignFirstResponder()
    }
}

extension DiscoverPageViewController {
    private func setupButtonTag() {
        let buttons = buttonStackView.subviews
        for (index, button) in buttons.enumerated() {
            if let uibutton = button as? UIButton {
                uibutton.tag = index
                uibutton.addTarget(self, action: #selector(changePage), for: .touchUpInside)
            }
        }
    }
    
    @objc func changePage(sender: UIButton) {
        let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        nftSearchBar.text = ""
        isSearching = false
        searchedNFTs.removeAll()
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        hideHeaderLoader()
        hideFooterLoader()
        if sender.tag == 0 {
            if selectedPage == 0 { return }
            selectedPage = 0
            if trendingNFTs.count == 0 {
                queue.async { [weak self] in
                    self?.getTrending()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                        layout.clearCache()
                    }
                    self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
                    self?.discoverCollectionView.reloadData()
                }
            }
        } else {
            if selectedPage == 1 { return }
            selectedPage = 1
            if let cachedData = recommendationCache, !cachedData.isEmpty {
                self.recommendedNFTs = cachedData
                self.updateRecommendationUI()
            } else {
                BCProgressHUD.show(text: "AI calculating...")
                fetchRecommendationData()
            }
        }
        self.discoverCollectionView.reloadData()
        discoverCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        // 動畫
        underlineViewWidthConstraint.isActive = false
        underlineViewCenterXConstraint.isActive = false
        underlineViewTopConstraint.isActive = false
        underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: sender.widthAnchor)
        underlineViewCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: sender.bottomAnchor)
        underlineViewWidthConstraint.isActive = true
        underlineViewCenterXConstraint.isActive = true
        underlineViewTopConstraint.isActive = true
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }.startAnimation()
        
        updateButtonColors(for: sender.tag)
    }
    
    private func updateButtonColors(for tag: Int) {
        trendingButton.tintColor = tag == 0 ? .secondary : .secondaryBlur
        forYouButton.tintColor = tag == 1 ? .secondary : .secondaryBlur
    }
}
