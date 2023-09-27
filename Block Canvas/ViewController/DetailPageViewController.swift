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
    
    var isWatchlistButtonSelected: Bool = false
    
    private let detailTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DetailImageCell.self, forCellReuseIdentifier: DetailImageCell.reuseIdentifier)
        tableView.register(DetailMetadataCell.self, forCellReuseIdentifier: DetailMetadataCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        return tableView
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfInWatchlist()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        setupUI()
        setupNavBarTitle()
        setupButtons()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        detailTableView.backgroundColor = .primary
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleStackView)
        
        view.addSubview(detailTableView)
        detailTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
    }
    
    private func watchlistButtonImage() -> UIImage? {
        return isWatchlistButtonSelected ? UIImage(systemName: "heart.fill")?.withTintColor(.tertiary, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")
    }
    
    private func setupButtons() {
        navigationItem.hidesBackButton = true
        let watchlistButton = UIBarButtonItem(image: watchlistButtonImage(), style: .plain, target: self, action: #selector(watchlistButtonTapped))
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItems = [closeButton, watchlistButton]
    }
    
    private func setupNavBarTitle() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            titleStackViewTitleLabel.text = discoverNFTMetadata.title
            titleStackViewArtistLabel.text = discoverNFTMetadata.authorName
        }
    }
    
    private func checkIfInWatchlist() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            isWatchlistButtonSelected = WatchlistManager.shared.isInWatchlist(nft: discoverNFTMetadata)
        }
    }
    
    private func updateWatchlistButtonImage() {
        if let watchlistButton = navigationItem.rightBarButtonItems?.last {
            DispatchQueue.main.async { [weak self] in
                watchlistButton.image = self?.watchlistButtonImage()
            }
        }
    }
    
    @objc func watchlistButtonTapped() {
        isWatchlistButtonSelected.toggle()
        
        if let discoverNFTMetadata = discoverNFTMetadata {
            if isWatchlistButtonSelected {
                WatchlistManager.shared.saveToWatchlist(discoverNFTAdded: discoverNFTMetadata)
            } else {
                if let indexPath = indexPath {
                    if let delegate = delegate {
                        delegate.deleteWatchlistItem(at: indexPath)
                    } else {
                        WatchlistManager.shared.deleteWatchlistItem(at: indexPath)
                    }
                }
            }
        }
        updateWatchlistButtonImage()
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension DetailPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let detailImageCell = detailTableView.dequeueReusableCell(withIdentifier: DetailImageCell.reuseIdentifier, for: indexPath) as? DetailImageCell else {
                fatalError("Cannot create detail image cell.")
            }
            if let discoverNFTMetadata = discoverNFTMetadata {
                detailImageCell.detailImageView.loadImage(discoverNFTMetadata.displayUri, placeHolder: UIImage(systemName: "circle.dotted"))
                detailImageCell.detailImageView.contentMode = .scaleAspectFit
                detailImageCell.descriptionLabel.text = discoverNFTMetadata.nftDescription
            }
            return detailImageCell
            
        } else {
            guard let detailMetadataCell = detailTableView.dequeueReusableCell(withIdentifier: DetailMetadataCell.reuseIdentifier, for: indexPath) as? DetailMetadataCell else {
                fatalError("Cannot create detail metadata cell.")
            }
            if let discoverNFTMetadata = discoverNFTMetadata {
                detailMetadataCell.detailView.titleLabel.text = discoverNFTMetadata.title
                detailMetadataCell.detailView.artistLabel.text = discoverNFTMetadata.authorName
                detailMetadataCell.detailView.contractLabel.text = discoverNFTMetadata.contract
            }
            return detailMetadataCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            self.detailTableView.performBatchUpdates(nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = self.detailTableView.cellForRow(at: indexPath) as? DetailMetadataCell {
            cell.hideDetailView()
        }
    }
}
