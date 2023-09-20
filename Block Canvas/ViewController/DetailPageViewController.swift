//
//  DetailPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit

class DetailPageViewController: UIViewController {
    var discoverNFTMetadata: DiscoverNFT?
    
//    @IBOutlet weak var imageView: UIImageView!
    
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
    
//    let descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16)
//        label.numberOfLines = 0
//        return label
//    }()
    
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
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(550)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
        
        view.addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
        
        view.addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-12)
        }
    }
    
    private func setupContent() {
        if let discoverNFTMetadata = discoverNFTMetadata {
            imageView.loadImage(discoverNFTMetadata.displayUri)
            imageView.contentMode = .scaleAspectFit
            titleLabel.text = discoverNFTMetadata.title
            artistLabel.text = discoverNFTMetadata.authorName
            contractLabel.text = discoverNFTMetadata.contract
        }
    }
}
