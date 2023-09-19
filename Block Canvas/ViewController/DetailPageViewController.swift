//
//  DetailPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit

class DetailPageViewController: UIViewController {
    var discoverNFTMetadata: DiscoverNFT?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var contractLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let discoverNFTMetadata = discoverNFTMetadata {
            imageView.loadImage(discoverNFTMetadata.displayUri)
            imageView.contentMode = .scaleAspectFit
            titleLabel.text = discoverNFTMetadata.title
            artistLabel.text = discoverNFTMetadata.authorName
            descriptionLabel.text = ""
            contractLabel.text = discoverNFTMetadata.contract
        }
    }
}
