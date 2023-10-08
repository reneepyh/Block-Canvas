//
//  ViewController.swift
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
    
    private var openAIBody: OpenAIBody?
    
    private var userNFTs: [String] = []
    
    private var trendingNFTs: [DiscoverNFT] = []
    
    private var searchedNFTs: [DiscoverNFT] = []
    
    private var isSearching: Bool = false
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var recommendedResponse: String?
    
    private var recommendedCollections: [String] = []
    
    private var recommendedNFTs: [DiscoverNFT] = []
    
    private var recommendationCache: [DiscoverNFT]?
    
    private let group = DispatchGroup()
    
    private let apiService = DiscoverAPIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupButtonTag()
        nftSearchBar.delegate = self
        getTrending()
        fetchRecommendationInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
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
            if self?.selectedPage == 0 {
                self?.getTrending()
            } else if self?.selectedPage == 1 {
                BCProgressHUD.show(text: "AI calculating...")
                self?.fetchRecommendationData()
            }
        })
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        underlineView.backgroundColor = .secondary
        trendingButton.tintColor = .secondary
        forYouButton.tintColor = .secondaryBlur
        nftSearchBar.searchTextField.backgroundColor = .tertiary
        nftSearchBar.searchTextField.textColor = .primary
        nftSearchBar.searchTextField.clearButtonMode = .unlessEditing
        nftSearchBar.searchTextField.autocapitalizationType = .none
        nftSearchBar.searchTextField.autocorrectionType = .no
        
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
        apiService.searchNFT(keyword: keyword) { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.searchedNFTs = nfts
                DispatchQueue.main.async {
                    self?.discoverCollectionView.reloadData()
                }
                BCProgressHUD.dismiss()
            case .failure(let error):
                if (error as NSError).code == NSURLErrorTimedOut {
                    BCProgressHUD.showFailure(text: "Request timed out. Please try again.")
                } else {
                    BCProgressHUD.showFailure(text: "No NFT found.")
                }
            }
        }
    }
    
    private func fetchRecommendationData(isBackground: Bool = false) {
        findUserNFTs()
        searchedNFTs.removeAll()
        recommendedNFTs.removeAll()
        
        getRecommendationFromGPT()
        semaphore.wait()
        
        self.formatCollectionName()
        
        for collection in recommendedCollections {
            group.enter()
            self.getRecommendedNFTs(collectionName: collection)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.recommendationCache = self?.recommendedNFTs
            if !isBackground {
                self?.updateRecommendationUI()
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
    
    private func getRecommendationFromGPT() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("OpenAI API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
            var request = URLRequest(url: url)
            request.setValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(key)",
                             forHTTPHeaderField: "Authorization")
            if userNFTs.isEmpty {
                openAIBody = OpenAIBody(messages: [
                    ["role": "user", "content": """
               Please suggest art NFT collections. Suggest NFT collections should be on Ethereum blockchain. Please suggest 5 NFT collections. Provide only the collection names in bullet pointsc (not numbered lists) and not any other responses. Please do not mention the artist's name. Please do not include double quotes for the response. Please also do not include symbols such as colon, semicolon or dash.
               """]
                ])
                
            } else {
                var randomNFTs: [String] = []
                randomNFTs.append(userNFTs.randomElement() ?? "")
                randomNFTs.append(userNFTs.randomElement() ?? "")
                randomNFTs.append(userNFTs.randomElement() ?? "")
                print(randomNFTs)
                
                openAIBody = OpenAIBody(messages: [
                    ["role": "user", "content": """
               Generate recommendations for NFT collections similar to the following:
               
               Collection Name: \(randomNFTs)
               Hosted blockchain: Ethereum
               
               Please suggest NFT collections that share similarities with the provided collection. Suggest NFT collections should be on Ethereum blockchain. Please suggest 5 NFT collections. Provide only the collection names in bullet pointsc (not numbered lists) and not any other responses. Please do not mention the artist's name. Please do not include double quotes for the response. Please also do not include symbols such as colon, semicolon or dash.
               """]
                ])
            }
            
            request.httpBody = try? JSONEncoder().encode(openAIBody)
            request.httpMethod = "POST"
            
            if let postData = try? JSONEncoder().encode(openAIBody) {
                if let jsonString = String(data: postData, encoding: .utf8) {
                    print("Request JSON: \(jsonString)")
                }
                request.httpBody = postData
            } else {
                print("Failed to encode the JSON data")
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let data = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                        self?.recommendedResponse = data.choices?[0].message?.content
                        print("response: \(self?.recommendedResponse)")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }
                if let error = error {
                    print("Error when post request to GPT API:\(error)")
                    
                }
                self?.semaphore.signal()
            }.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func formatCollectionName() {
        guard let recommendedResponse = recommendedResponse else {
            print("No response from GPT.")
            return
        }
        self.recommendedCollections = recommendedResponse.split(separator: "\n").map { line -> String in
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.hasPrefix("-") {
                let collectionName = String(trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces))
                return collectionName.replacingOccurrences(of: " ", with: "")
            } else {
                return trimmedLine.replacingOccurrences(of: " ", with: "")
            }
        }
        print(recommendedCollections)
    }
    
    private func getRecommendedNFTs(collectionName: String) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Reservoir_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Reservoir API Key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.reservoir.tools/search/collections/v2?name=\(collectionName)&limit=3") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 4.0
            configuration.timeoutIntervalForResource = 4.0
            
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                defer { self?.group.leave() }
                
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
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    var nftDescription = ""
                    for searchResult in searchData.collections ?? [] {
                        if let slug = searchResult.slug {
                            nftDescription = "https://opensea.io/collection/\(slug)"
                        } else {
                            nftDescription = ""
                        }
                        self?.recommendedNFTs.append(DiscoverNFT(thumbnailUri: searchResult.image ?? "", displayUri: searchResult.image ?? "", contract: searchResult.contract ?? "", title: searchResult.name, authorName: "", nftDescription: nftDescription))
                    }
                }
                catch {
                    print("Error in JSON decoding.")
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
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
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        
        if let searchText = nftSearchBar.text, searchText != "" {
            isSearching = true
            searchNFT(keyword: searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
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
