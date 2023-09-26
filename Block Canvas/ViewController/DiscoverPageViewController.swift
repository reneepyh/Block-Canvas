//
//  ViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/13.
//

import UIKit
// swiftlint: disable type_body_length
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
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var recommendedResponse: String?
    
    private var recommendedCollections: [String] = []
    
    private var recommendedNFTs: [DiscoverNFT] = []
    
    private let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonTag()
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        nftSearchBar.delegate = self
        getTrending()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        underlineView.backgroundColor = .secondary
        trendingButton.tintColor = .secondary
        forYouButton.tintColor = .secondaryBlur
        nftSearchBar.searchTextField.backgroundColor = .tertiary
        nftSearchBar.searchTextField.textColor = .primary
        discoverCollectionView.backgroundColor = .primary
        
        let layout = WaterFallFlowLayout()
        layout.delegate = self
        layout.cols = 2
        discoverCollectionView.collectionViewLayout = layout
        
        let navigationExtendHeight: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        navigationController?.additionalSafeAreaInsets = navigationExtendHeight
    }
    
    private func getTrending() {
        trendingNFTs.removeAll()
        searchedNFTs.removeAll()
        recommendedNFTs.removeAll()
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        BCProgressHUD.show()
        let group = DispatchGroup()
        func fetchToken() {
            group.enter()
            let url = URL(string: "https://api.fxhash.xyz/graphql")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let query = """
            {
               randomTopGenerativeToken {
                  author {
                    name
                  }
                  gentkContractAddress
                  issuerContractAddress
                  metadata
                }
            }
            """
            
            let json: [String: Any] = ["query": query]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                defer {
                    group.leave()
                }
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let root = try decoder.decode(Root.self, from: data)
                    if self?.trendingNFTs.contains(where: { $0.title == root.data.randomTopGenerativeToken.metadata.name }) == true {
                        fetchToken()
                        return
                    }
                    
                    let contract = root.data.randomTopGenerativeToken.gentkContractAddress
                    let thumbnailURL = self?.generativeLiveDisplayUrl(uri: root.data.randomTopGenerativeToken.metadata.thumbnailUri)
                    let displayURL = self?.generativeLiveDisplayUrl(uri: root.data.randomTopGenerativeToken.metadata.displayUri)
                    let authorName = root.data.randomTopGenerativeToken.author?.name
                    let title = root.data.randomTopGenerativeToken.metadata.name
                    let description = root.data.randomTopGenerativeToken.metadata.description
                    self?.trendingNFTs.append(DiscoverNFT(thumbnailUri: thumbnailURL ?? "", displayUri: displayURL ?? "", contract: contract, title: title, authorName: authorName, nftDescription: description))
                } catch {
                    print("Error: \(error)")
                }
            }
            task.resume()
        }
        for _ in 0..<10 {
            fetchToken()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.discoverCollectionView.reloadData()
            BCProgressHUD.dismiss()
        }
    }
    
    private func searchNFT(keyword: String) {
        BCProgressHUD.show(text: "Searching")
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NFTPort_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("NFTPort API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.nftport.xyz/v0/search?text=\(keyword.lowercased())&chain=ethereum&page_number=1&page_size=10&order_by=relevance&sort_order=desc") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "Authorization")
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
                    BCProgressHUD.showFailure(text: "No NFT found.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    print(searchData)
                    for searchResult in searchData.searchResults ?? [] {
                        self?.searchedNFTs.append(DiscoverNFT(thumbnailUri: searchResult.cachedFileURL ?? "", displayUri: searchResult.cachedFileURL ?? "", contract: searchResult.contractAddress ?? "", title: searchResult.name, authorName: "", nftDescription: searchResult.description))
                    }
                    print(self?.searchedNFTs)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.discoverCollectionView.reloadData()
                }
                BCProgressHUD.dismiss()
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func fetchRecommendation() {
        BCProgressHUD.show(text: "AI calculating...")
        findUserNFTs()
        trendingNFTs.removeAll()
        searchedNFTs.removeAll()
        recommendedNFTs.removeAll()
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.discoverCollectionView.collectionViewLayout as? WaterFallFlowLayout {
                layout.clearCache()
            }
            self?.discoverCollectionView.collectionViewLayout.invalidateLayout()
            self?.discoverCollectionView.reloadData()
        }
        getRecommendationFromGPT()
        semaphore.wait()
        
        self.formatCollectionName()
        
        for collection in recommendedCollections {
            group.enter()
            self.getRecommendedNFTs(collectionName: collection)
        }
        group.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
                self?.discoverCollectionView.reloadData()
                BCProgressHUD.dismiss()
            }
        }
    }
    
    private func getRecommendationFromGPT() {
        //TODO: error handle不遵照格式
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("OpenAI API key does not exist.")
            return
        }
        
        var randomNFTs: [String] = []
        randomNFTs.append(userNFTs.randomElement() ?? "")
        randomNFTs.append(userNFTs.randomElement() ?? "")
        randomNFTs.append(userNFTs.randomElement() ?? "")
        print(randomNFTs)
        
        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
            var request = URLRequest(url: url)
            request.setValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(key)",
                             forHTTPHeaderField: "Authorization")
            let openAIBody = OpenAIBody(messages: [
                ["role": "user", "content": """
           Generate recommendations for NFT collections similar to the following:
           
           Collection Name: \(randomNFTs)
           Hosted blockchain: Ethereum
           
           Please suggest NFT collections that share similarities with the provided collection. Suggest NFT collections should be on Ethereum blockchain. Please suggest 5 NFT collections. Provide only the collection names in bullet pointsc (not numbered lists) and not any other responses. Please not to mention the artist's name. Please do not include double quotes for the response. Please also do not include symbols such as colon, semicolon or dash.
           """]
            ])
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
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NFTPort_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("NFTPort API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.nftport.xyz/v0/search?text=\(collectionName)&chain=ethereum&page_number=1&page_size=5&order_by=mint_date&sort_order=desc") {
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(key, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 2.0
            configuration.timeoutIntervalForResource = 2.0
            
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                defer { self?.group.leave() }
                
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
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    print(searchData)
                    for searchResult in searchData.searchResults ?? [] {
                        self?.recommendedNFTs.append(DiscoverNFT(thumbnailUri: searchResult.cachedFileURL ?? "", displayUri: searchResult.cachedFileURL ?? "", contract: searchResult.contractAddress ?? "", title: searchResult.name, authorName: "", nftDescription: searchResult.description))
                    }
                    print(self?.recommendedNFTs)
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
            discoverCollectionCell.imageView.loadImage(searchedNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(systemName: "circle.dotted"))
            discoverCollectionCell.titleLabel.text = searchedNFTs[indexPath.row].title
        } else if selectedPage == 0 {
            discoverCollectionCell.imageView.loadImage(trendingNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(systemName: "circle.dotted"))
            discoverCollectionCell.titleLabel.text = trendingNFTs[indexPath.row].title
        } else {
            discoverCollectionCell.imageView.loadImage(recommendedNFTs[indexPath.row].thumbnailUri, placeHolder: UIImage(systemName: "circle.dotted"))
            discoverCollectionCell.titleLabel.text = recommendedNFTs[indexPath.row].title
        }
        
        return discoverCollectionCell
    }
    
    func waterFlowLayout(_ waterFlowLayout: WaterFallFlowLayout, itemHeight indexPath: IndexPath) -> CGFloat {
        return CGFloat.random(in: 230...400)
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
        } else if selectedPage == 0 {
            detailVC.discoverNFTMetadata = trendingNFTs[indexPath.row]
        } else {
            detailVC.discoverNFTMetadata = recommendedNFTs[indexPath.row]
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
    private func generativeLiveDisplayUrl(uri: String) -> String {
        let gateway = "https://gateway.fxhash.xyz/ipfs/"
        let startIndex = uri.index(uri.startIndex, offsetBy: 7)
        let newUri = String(uri[startIndex...])
        return gateway + newUri
    }
    
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
        if sender.tag == 0 {
            selectedPage = 0
            queue.async { [weak self] in
                self?.getTrending()
            }
        } else {
            selectedPage = 1
            queue.async { [weak self] in
                self?.fetchRecommendation()
            }
        }
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
