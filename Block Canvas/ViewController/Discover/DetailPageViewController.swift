//
//  DetailPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit
import WebKit

protocol DetailPageViewControllerDelegate: AnyObject {
    func deleteWatchlistItem(at indexPath: IndexPath)
}

class DetailPageViewController: UIViewController {
    var discoverNFTMetadata: DiscoverNFT?
    
    var delegate: DetailPageViewControllerDelegate?
    
    var indexPath: IndexPath?
    
    var isWatchlistButtonSelected: Bool = false
    
    var isProcessing: Bool = false
    
    var isDetailViewHidden: Bool = true
    
    private let detailTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DetailImageCell.self, forCellReuseIdentifier: DetailImageCell.reuseIdentifier)
        tableView.register(DetailMetadataCell.self, forCellReuseIdentifier: DetailMetadataCell.reuseIdentifier)
        tableView.register(DetailMetadataInfoCell.self, forCellReuseIdentifier: DetailMetadataInfoCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let titleStackViewTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .secondary
        label.numberOfLines = 0
        label.font = UIFont.main(ofSize: 16)
        return label
    }()
    
    private let titleStackViewArtistLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .tertiary
        label.font = UIFont.main(ofSize: 14)
        return label
    }()
    
    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleStackViewTitleLabel, self.titleStackViewArtistLabel])
        stackView.axis = .vertical
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfInWatchlist()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        setupUI()
        setupNavBarTitle()
        setupButtons()
    }
}

// MARK: - UI Functions
extension DetailPageViewController {
    private func setupUI() {
        view.backgroundColor = .primary
        detailTableView.backgroundColor = .primary
        detailTableView.separatorStyle = .none
        detailTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleStackView)
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(detailTableView)
        detailTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
        }
    }
    
    private func watchlistButtonImage() -> UIImage? {
        return isWatchlistButtonSelected ? UIImage(systemName: "heart.fill")?.withTintColor(.tertiary, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")
    }
    
    private func setupButtons() {
        navigationItem.hidesBackButton = true
        let watchlistButton = UIBarButtonItem(image: watchlistButtonImage(), style: .plain, target: self, action: #selector(watchlistButtonTapped))
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
        let arButton = UIBarButtonItem(image: UIImage(systemName: "dot.circle.viewfinder"), style: .plain, target: self, action: #selector(arButtonTapped))
        navigationItem.rightBarButtonItems = [closeButton, watchlistButton, arButton]
    }
    
    private func setupNavBarTitle() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            titleStackViewTitleLabel.text = discoverNFTMetadata.title
            titleStackViewArtistLabel.text = discoverNFTMetadata.authorName
        }
    }
    
    private func updateWatchlistButtonImage() {
        if let watchlistButton = navigationItem.rightBarButtonItems?[1] {
            DispatchQueue.main.async { [weak self] in
                watchlistButton.image = self?.watchlistButtonImage()
            }
        }
    }
}

// MARK: - Functions
extension DetailPageViewController {
    private func checkIfInWatchlist() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            isWatchlistButtonSelected = WatchlistManager.shared.isInWatchlist(nft: discoverNFTMetadata)
        }
    }
    
    @objc func watchlistButtonTapped() {
        if isProcessing { return }
        isProcessing = true
        
        isWatchlistButtonSelected.toggle()
        
        if let discoverNFTMetadata = discoverNFTMetadata {
            if isWatchlistButtonSelected {
                WatchlistManager.shared.saveToWatchlist(discoverNFTAdded: discoverNFTMetadata)
            } else {
                WatchlistManager.shared.deleteWatchlistItem(with: discoverNFTMetadata.displayUri)
            }
        }
        updateWatchlistButtonImage()
        
        isProcessing = false
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func arButtonTapped() {
        BCProgressHUD.show()
        let arViewController = ARDisplayViewController()
        guard let displayUri = discoverNFTMetadata?.displayUri else {
            print("Cannot find display Uri.")
            BCProgressHUD.showFailure(text: BCConstant.internetError)
            return
        }
        
        guard let imageURL = URL(string: displayUri) else {
            print("Cannot create image URL.")
            BCProgressHUD.showFailure(text: BCConstant.internetError)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                BCProgressHUD.showFailure(text: BCConstant.internetError)
            } else if let data = data, let image = UIImage(data: data) {
                arViewController.imageToDisplay = image
                DispatchQueue.main.async {
                    arViewController.modalPresentationStyle = .overFullScreen
                    BCProgressHUD.dismiss()
                    self.present(arViewController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
}

// MARK: - Table View
extension DetailPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isDetailViewHidden ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
                guard let detailImageCell = detailTableView.dequeueReusableCell(withIdentifier: DetailImageCell.reuseIdentifier, for: indexPath) as? DetailImageCell else {
                    fatalError("Cannot create detail image cell.")
                }
                if let discoverNFTMetadata = discoverNFTMetadata {
                    detailImageCell.detailImageView.loadImage(discoverNFTMetadata.displayUri, placeHolder: UIImage(named: "placeholder"))
                    detailImageCell.detailImageView.contentMode = .scaleAspectFit
                    detailImageCell.descriptionLabel.text = discoverNFTMetadata.nftDescription
                }
                return detailImageCell
        case 1:
                guard let detailMetadataCell = detailTableView.dequeueReusableCell(withIdentifier: DetailMetadataCell.reuseIdentifier, for: indexPath) as? DetailMetadataCell else {
                    fatalError("Cannot create detail metadata cell.")
                }
                if isDetailViewHidden {
                    detailMetadataCell.arrowImageView.image = UIImage(systemName: "chevron.down")?.withTintColor(.tertiary, renderingMode: .alwaysOriginal)
                } else {
                    detailMetadataCell.arrowImageView.image = UIImage(systemName: "chevron.up")?.withTintColor(.tertiary, renderingMode: .alwaysOriginal)
                }
                return detailMetadataCell
        case 2:
                guard let detailMetadataInfoCell = detailTableView.dequeueReusableCell(withIdentifier: DetailMetadataInfoCell.reuseIdentifier, for: indexPath) as? DetailMetadataInfoCell else {
                    fatalError("Cannot create detail image cell.")
                }
                if let discoverNFTMetadata = discoverNFTMetadata {
                    detailMetadataInfoCell.titleLabel.text = discoverNFTMetadata.title
                    detailMetadataInfoCell.artistLabel.text = discoverNFTMetadata.authorName
                    if discoverNFTMetadata.contract.hasPrefix("K") {
                        detailMetadataInfoCell.tokenButton.setTitle("fx(hash)", for: .normal)
                    } else {
                        detailMetadataInfoCell.tokenButton.setTitle("OpenSea", for: .normal)
                    }
                    detailMetadataInfoCell.delegate = self
                }
                return detailMetadataInfoCell
        default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // Metadata label tapped
            isDetailViewHidden.toggle()
            tableView.reloadData()
        }
    }
}

// MARK: - DetailMetadataInfoCellDelegate
extension DetailPageViewController: DetailMetadataInfoCellDelegate {
    func tokenTapped() {
        if let contract = discoverNFTMetadata?.contract {
            var tokenURL: URL?
            if contract.hasPrefix("K") {
                if let id = discoverNFTMetadata?.id, let fxhashURL = URL(string: "https://www.fxhash.xyz/marketplace/generative/\(id)") {
                    tokenURL = fxhashURL
                }
            } else {
                if let openseaDescription = discoverNFTMetadata?.nftDescription, let openseaURL = URL(string: openseaDescription) {
                    tokenURL = openseaURL
                }
            }
            let webViewController = PlatformWebViewController()
            webViewController.urlString = tokenURL?.absoluteString
            
            let navController = UINavigationController(rootViewController: webViewController)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            present(navController, animated: true, completion: nil)
        }
    }
}

// MARK: - Web View
class PlatformWebViewController: UIViewController {
    private var webView: WKWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.frame = view.bounds
        view.addSubview(webView)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
