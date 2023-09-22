//
//  watchlistCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/21.
//

import UIKit

class WatchlistCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: WatchlistCell.self)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottom)
//            make.width.equalTo(160)
        }
    }
}
