//
//  DetailPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit

protocol DetailPageViewControllerDelegate: AnyObject {
    func deleteWatchlistItem(at indexPath: IndexPath)
}

class DetailPageViewController: UIViewController {
    var discoverNFTMetadata: DiscoverNFT?
    
    var delegate: DetailPageViewControllerDelegate?
    
    var indexPath: IndexPath?
    
    var isNFTInWatchlist: Bool {
        if let discoverNFTMetadata = discoverNFTMetadata {
            return WatchlistManager.shared.isInWatchlist(nft: discoverNFTMetadata)
        }
        return false
    }
    
    private let titleStackViewTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .secondary
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
        stackView.spacing = 4
        return stackView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let contractLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        setupButtons()
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleStackView)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(550)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
        
        view.addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
        
        view.addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
    }
    
    private func watchlistButtonImage() -> UIImage? {
        return isNFTInWatchlist ? UIImage(systemName: "heart.fill")?.withTintColor(.tertiary, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")
    }
    
    private func setupButtons() {
        navigationItem.hidesBackButton = true
        let watchlistButton = UIBarButtonItem(image: watchlistButtonImage(), style: .plain, target: self, action: #selector(watchlistButtonTapped))
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItems = [closeButton, watchlistButton]
    }
    
    private func setupContent() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            imageView.loadImage(discoverNFTMetadata.displayUri, placeHolder: UIImage(systemName: "circle.dotted"))
            imageView.contentMode = .scaleAspectFit
            titleLabel.text = discoverNFTMetadata.title
            artistLabel.text = discoverNFTMetadata.authorName
            contractLabel.text = "Contract: \(discoverNFTMetadata.contract)"
            descriptionLabel.text = discoverNFTMetadata.nftDescription
            
            titleStackViewTitleLabel.text = discoverNFTMetadata.title
            titleStackViewArtistLabel.text = discoverNFTMetadata.authorName
        }
    }
    
    private func updateWatchlistButtonImage() {
        if let watchlistButton = navigationItem.rightBarButtonItems?.last {
            watchlistButton.image = watchlistButtonImage()
        }
    }
    
    @objc func watchlistButtonTapped() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            if isNFTInWatchlist, let indexPath = indexPath {
                delegate?.deleteWatchlistItem(at: indexPath)
            } else {
                WatchlistManager.shared.saveToWatchlist(discoverNFTAdded: discoverNFTMetadata)
            }
        }
        updateWatchlistButtonImage()
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
