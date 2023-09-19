//
//  ViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/13.
//

import UIKit
import Apollo

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
    
    private let selectedColor = UIColor(red: 63/256, green: 58/256, blue: 58/256, alpha: 1)
    
    private let unselectedColor = UIColor(red: 136/256, green: 136/256, blue: 136/256, alpha: 1)
    
    private var trendingNFTs: [DiscoverNFT] = []
    
    private var searchedNFTs: [DiscoverNFT] = []
    
    private var isSearching: Bool = false
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let apolloClient = ApolloClient(url: URL(string: "https://api.fxhash.xyz/graphql")!)
    
    private var recommendedResponse: String?
    
    //    private var recommendedCollections: [ArtCollection] = []
    
    private var recommendedContracts: [String] = []
    
    //    private var recommendedNFTs: [NFTForFetch] = []
    //
    //    private var recommendedNFTMetadatum: [NFTMetadatum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trendingButton.tintColor = selectedColor
        forYouButton.tintColor = unselectedColor
        setupButtonTag()
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        nftSearchBar.delegate = self
        getTrending()
        
        //        getRecommendationFromGPT()
        //        fetchData()
    }
    
    private func getTrending() {
        trendingNFTs.removeAll()
        let group = DispatchGroup()
        //        let queue = DispatchQueue(label: "queue", attributes: .concurrent)
        for _ in 0...9 {
            //TODO: 判斷回應相同NFT
            group.enter()
            apolloClient.fetch(query: GetTrending.GetTrendingQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { [weak self] result in
                defer { group.leave() }
                guard let data = try? result.get().data else { return }
                let displayURL = self?.generativeLiveDisplayUrl(uri: data.randomTopGenerativeToken.displayUri ?? "")
                let authorName = data.randomTopGenerativeToken.author.name
                let title = data.randomTopGenerativeToken.name
                let thumbnailURL = self?.generativeLiveDisplayUrl(uri: data.randomTopGenerativeToken.thumbnailUri ?? "")
                let contract = data.randomTopGenerativeToken.gentkContractAddress
                self?.trendingNFTs.append(DiscoverNFT(thumbnailUri: thumbnailURL ?? "", displayUri: displayURL ?? "", contract: contract, title: title, authorName: authorName))
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.discoverCollectionView.reloadData()
        }
    }
    
    private func searchNFT(keyword: String) {
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
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let searchData = try decoder.decode(SearchNFT.self, from: data)
                    for searchResult in searchData.searchResults ?? [] {
                        self?.searchedNFTs.append(DiscoverNFT(thumbnailUri: searchResult.cachedFileURL ?? "", displayUri: searchResult.cachedFileURL ?? "", contract: searchResult.contractAddress ?? "", title: searchResult.name, authorName: ""))
                    }
                    print(self?.searchedNFTs)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.discoverCollectionView.reloadData()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    //    private func fetchData() {
    //        getRecommendationFromGPT()
    //        semaphore.wait()
    //
    //        self.formatCollectionName()
    //        semaphore.wait()
    //
    //        for collection in self.recommendedCollections {
    //            self.getRecommendedContracts(collectionName: collection.collectionName)
    //        }
    //
    //        semaphore.signal()
    //        for contract in self.recommendedContracts {
    //            self.getNFTByContract(address: contract)
    //        }
    //
    //        semaphore.signal()
    //        for NFTForFetch in self.recommendedNFTs {
    //            self.getNFTMetadata(NFTToFetch: NFTForFetch)
    //        }
    //
    //    }
    
    //    private func getRecommendationFromGPT() {
    //        //TODO: error handle不遵照格式
    //        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
    //
    //        guard let key = apiKey, !key.isEmpty else {
    //            print("OpenAI API key does not exist.")
    //            return
    //        }
    //
    //        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
    //            var request = URLRequest(url: url)
    //            request.setValue("application/json",
    //                             forHTTPHeaderField: "Content-Type")
    //            request.setValue("Bearer \(key)",
    //                             forHTTPHeaderField: "Authorization")
    //            let openAIBody = OpenAIBody(messages: [
    //                ["role": "user", "content": """
    //       Generate recommendations for NFT collections similar to the following:
    //
    //       Collection Name: The Art of Seasons
    //       Artist Name: Dirty Robot
    //       Hosted blockchain: Ethereum
    //       Collection Contract Address: 0x5bd815fd6c096bab38b4c6553cfce3585194dff9
    //
    //       Please suggest NFT collections that share similarities with the provided collection. Suggest NFT collections should be on Ethereum blockchain. Consider factors such as the artist's style, theme, or genre of artwork. Please suggest 5 NFT collections. Provide only the collection names and artist names in bullet points and not any other responses.
    //
    //       Ensure the recommendations are art NFT collections.
    //       """]
    //            ])
    //            request.httpBody = try? JSONEncoder().encode(openAIBody)
    //            request.httpMethod = "POST"
    //
    //            if let postData = try? JSONEncoder().encode(openAIBody) {
    //                if let jsonString = String(data: postData, encoding: .utf8) {
    //                    print("Request JSON: \(jsonString)")
    //                }
    //                request.httpBody = postData
    //            } else {
    //                print("Failed to encode the JSON data")
    //            }
    //
    //            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
    //                if let data = data {
    //                    do {
    //                        let data = try JSONDecoder().decode(OpenAIResponse.self, from: data)
    //                        self?.recommendedResponse = data.choices?[0].message?.content
    //                        print("response: \(self?.recommendedResponse)")
    //                        //                        DispatchQueue.main.async {
    //                        //                            if let response = data.choices?[0].message?.content, let self = self {
    //                        //                                print(response)
    //                        //                                let regexPattern = "Collection Name: \"([^\"]+)\"\\s+Artist Name: (\\w+)"
    //                        //
    //                        //                                do {
    //                        //                                    let regex = try NSRegularExpression(pattern: regexPattern, options: [])
    //                        //                                    let nsString = response as NSString
    //                        //                                    let matches = regex.matches(in: response, options: [], range: NSRange(location: 0, length: nsString.length))
    //                        //
    //                        //                                    for match in matches {
    //                        //                                        if let collectionRange = Range(match.range(at: 1), in: response),
    //                        //                                           let artistRange = Range(match.range(at: 2), in: response) {
    //                        //
    //                        //                                            let collectionName = String(response[collectionRange])
    //                        //                                            let trimmedCollection = String(collectionName.filter { !" ".contains($0) })
    //                        //                                            self.recommendedCollections.append(ArtCollection(collectionName: trimmedCollection))
    //                        //                                        }
    //                        //                                    }
    //                        //                                    print(self.recommendedCollections)
    //                        //                                } catch let error {
    //                        //                                    print("Failed to create regex: \(error.localizedDescription)")
    //                        //                                }
    //                        //
    //                        //                                //                                // Use extracted data
    //                        //                                //                                for collection in self.recommendedCollections {
    //                        //                                //                                    self.getRecommendedContracts(collectionName: collection.collectionName)
    //                        //                                //                                }
    //                        ////                            }
    //                        //                        }
    //                    } catch {
    //                        print(error.localizedDescription)
    //                    }
    //                }
    //                if let httpResponse = response as? HTTPURLResponse {
    //                    print("HTTP Status Code: \(httpResponse.statusCode)")
    //                }
    //                if let error = error {
    //                    print("Error when post request to GPT API:\(error)")
    //
    //                }
    //                self?.semaphore.signal()
    //            }.resume()
    //        }
    //        else {
    //            print("Invalid URL.")
    //        }
    //    }
    
    //    private func formatCollectionName() {
    //        let regexPattern = "Collection Name: \"([^\"]+)\"\\s+Artist Name: (\\w+)"
    //        do {
    //            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
    //            let nsString = recommendedResponse! as NSString
    //            let matches = regex.matches(in: recommendedResponse ?? "", options: [], range: NSRange(location: 0, length: nsString.length))
    //
    //            for match in matches {
    //                if let collectionRange = Range(match.range(at: 1), in: recommendedResponse  ?? ""),
    //                   let artistRange = Range(match.range(at: 2), in: recommendedResponse  ?? "") {
    //
    //                    let collectionName = String(recommendedResponse?[collectionRange] ?? "")
    //                    let trimmedCollection = String(collectionName.filter { !" ".contains($0) })
    //                    self.recommendedCollections.append(ArtCollection(collectionName: trimmedCollection))
    //                }
    //            }
    //            print(self.recommendedCollections)
    //            semaphore.signal()
    //        } catch let error {
    //            print("Failed to create regex: \(error.localizedDescription)")
    //
    //
    //            //                                // Use extracted data
    //            //                                for collection in self.recommendedCollections {
    //            //                                    self.getRecommendedContracts(collectionName: collection.collectionName)
    //            //                                }
    //            //                            }
    //        }
    //    }
    
    //    private func getRecommendedContracts(collectionName: String) {
    //        semaphore.wait()
    //        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NFT_GO_API_Key") as? String
    //
    //        guard let key = apiKey, !key.isEmpty else {
    //            print("NFTGo API key does not exist.")
    //            return
    //        }
    //
    //        if let url = URL(string: "https://data-api.nftgo.io/eth/v1/collection/name/\(collectionName)") {
    //
    //            var request = URLRequest(url: url)
    //            request.setValue("application/json", forHTTPHeaderField: "Accept")
    //            request.setValue(key, forHTTPHeaderField: "X-API-Key")
    //            request.httpMethod = "GET"
    //
    //            let session = URLSession.shared
    //
    //            let task = session.dataTask(with: request) { data, response, error in
    //                if let error = error {
    //                    print(error)
    //                    return
    //                }
    //
    //                guard let data = data else {
    //                    print("No data.")
    //                    return
    //                }
    //
    //                let decoder = JSONDecoder()
    //
    //                do {
    //                    let data = try decoder.decode(SearchedNFT.self, from: data)
    //
    //                    //                    DispatchQueue.main.async { [weak self] in
    //                    for collection in data.collections ?? [] {
    //                        if data.total != 0 {
    //                            self.recommendedContracts.append(collection.contracts?[0] ?? "")
    //                        }
    //                    }
    //                    //                    }
    //                    //                    for contract in self.recommendedContracts {
    //                    //                        self.getNFTByContract(address: contract)
    //                    //                    }
    //                    print(self.recommendedContracts)
    //                }
    //                catch {
    //                    print("Error in JSON decoding.")
    //                }
    //                self.semaphore.signal()
    //            }
    //            task.resume()
    //        }
    //        else {
    //            print("Invalid URL.")
    //        }
    //    }
    
    //    private func getNFTByContract(address: String) {
    //        semaphore.wait()
    //        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
    //
    //        guard let key = apiKey, !key.isEmpty else {
    //            print("Moralis API key does not exist.")
    //            return
    //        }
    //
    //        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/nft/\(address)?chain=eth&format=decimal&limit=1") {
    //
    //            var request = URLRequest(url: url)
    //            request.setValue("application/json", forHTTPHeaderField: "Accept")
    //            request.setValue(key, forHTTPHeaderField: "X-API-Key")
    //            request.httpMethod = "GET"
    //
    //            let session = URLSession.shared
    //
    //            let task = session.dataTask(with: request) { data, response, error in
    //                if let error = error {
    //                    print(error)
    //                    return
    //                }
    //
    //                guard let data = data else {
    //                    print("No data.")
    //                    return
    //                }
    //
    //                let decoder = JSONDecoder()
    //
    //                do {
    //                    let NFTData = try decoder.decode(GetNFTByContract.self, from: data)
    //                    //                    DispatchQueue.main.async { [weak self] in
    //                    for NFT in NFTData.result ?? [] {
    //                        self.recommendedNFTs.append(NFTForFetch(tokenAddress: NFT.tokenAddress ?? "", tokenID: NFT.tokenID ?? ""))
    //                    }
    //                    //                    }
    //                    print(self.recommendedNFTs)
    //                    //                    for NFTMetadata in self.recommendedNFTs {
    //                    //                        self.getNFTMetadata(NFTToFetch: NFTMetadata)
    //                    //                    }
    //                }
    //                catch {
    //                    print("Error in JSON decoding.")
    //                }
    //                self.semaphore.signal()
    //            }
    //            task.resume()
    //        }
    //        else {
    //            print("Invalid URL.")
    //        }
    //    }
    
    //    private func getNFTMetadata(NFTToFetch: NFTForFetch) {
    //        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Moralis_API_Key") as? String
    //
    //        guard let key = apiKey, !key.isEmpty else {
    //            print("Moralis API key does not exist.")
    //            return
    //        }
    //
    //        if let url = URL(string: "https://deep-index.moralis.io/api/v2.2/nft/getMultipleNFTs") {
    //            var request = URLRequest(url: url)
    //            request.setValue("application/json",
    //                             forHTTPHeaderField: "Accept")
    //            request.setValue(key,
    //                             forHTTPHeaderField: "X-API-Key")
    //            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //            let requestBody = NFTMetadataRequest(tokens: [NFTToFetch], normalizeMetadata: true, mediaItems: true)
    //            request.httpBody = try? JSONEncoder().encode(requestBody)
    //            request.httpMethod = "POST"
    //
    //            if let postData = try? JSONEncoder().encode(requestBody) {
    //                if let jsonString = String(data: postData, encoding: .utf8) {
    //                    print("Request JSON: \(jsonString)")
    //                }
    //                request.httpBody = postData
    //            } else {
    //                print("Failed to encode the JSON data")
    //            }
    //
    //            let session = URLSession.shared
    //
    //            let task = session.dataTask(with: request) { data, response, error in
    //                if let error = error {
    //                    print(error)
    //                    return
    //                }
    //
    //                guard let data = data else {
    //                    print("No data.")
    //                    return
    //                }
    //
    //                let decoder = JSONDecoder()
    //
    //                do {
    //                    let NFTMetaData = try decoder.decode(NFTMetadatum.self, from: data)
    //                    DispatchQueue.main.async { [weak self] in
    //                        self?.recommendedNFTMetadatum.append(NFTMetaData)
    //                    }
    //                    print(self.recommendedNFTMetadatum)
    //                }
    //                catch {
    //                    print("Error in JSON decoding.")
    //                }
    //            }
    //            task.resume()
    //        }
    //        else {
    //            print("Invalid URL.")
    //        }
    //    }
}

extension DiscoverPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return searchedNFTs.count
        } else {
            return trendingNFTs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let discoverCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCollectionCell.reuseIdentifier, for: indexPath) as? DiscoverCollectionCell else {
            fatalError("Cell cannot be created")
        }
        if isSearching {
            discoverCollectionCell.imageView.loadImage(searchedNFTs[indexPath.row].thumbnailUri)
            discoverCollectionCell.imageView.contentMode = .scaleAspectFit
            discoverCollectionCell.titleLabel.text = searchedNFTs[indexPath.row].title
        } else {
            discoverCollectionCell.imageView.loadImage(trendingNFTs[indexPath.row].thumbnailUri)
            discoverCollectionCell.imageView.contentMode = .scaleAspectFit
            discoverCollectionCell.titleLabel.text = trendingNFTs[indexPath.row].title
        }
        
        return discoverCollectionCell
    }
    
    // 指定 item 寬度和數量
    //TODO: FIX flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 12 * 2
        let totalSapcing = CGFloat(5 * 2)
        
        let itemWidth = (maxWidth - totalSapcing) / 2
        return CGSize(width: itemWidth, height: itemWidth * 1.4)
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
        } else {
            detailVC.discoverNFTMetadata = trendingNFTs[indexPath.row]
        }
        show(detailVC, sender: nil)
    }
    
}

extension DiscoverPageViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedNFTs.removeAll()
        isSearching = true
        guard let searchText = nftSearchBar.text, searchText != "" else { return }
        searchNFT(keyword: searchText)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            getTrending()
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
        if sender.tag == 0 {
            getTrending()
        } else {
            // TODO: FOR YOU
            trendingNFTs.removeAll()
            discoverCollectionView.reloadData()
        }
        
        //先關閉
        underlineViewWidthConstraint.isActive = false
        underlineViewCenterXConstraint.isActive = false
        underlineViewTopConstraint.isActive = false
        //改值
        underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: sender.widthAnchor)
        underlineViewCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: sender.bottomAnchor)
        //再Active
        underlineViewWidthConstraint.isActive = true
        underlineViewCenterXConstraint.isActive = true
        underlineViewTopConstraint.isActive = true
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }.startAnimation()
        
        updateButtonColors(for: sender.tag)
    }
    
    private func updateButtonColors(for tag: Int) {
        trendingButton.tintColor = tag == 0 ? selectedColor : unselectedColor
        forYouButton.tintColor = tag == 1 ? selectedColor : unselectedColor
    }
}
