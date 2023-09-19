//
//  DetailPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit

class DetailPageViewController: UIViewController {
    var trendingNFTMetadata: DiscoverNFT?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var contractLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let trendingNFTMetadata = trendingNFTMetadata {
            imageView.loadImage(trendingNFTMetadata.displayUri)
            titleLabel.text = trendingNFTMetadata.title
            artistLabel.text = trendingNFTMetadata.authorName
            descriptionLabel.text = ""
            contractLabel.text = trendingNFTMetadata.contract
        }
    }
}
