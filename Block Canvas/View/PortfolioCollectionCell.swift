//
//  PortfolioCollectionCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit

class PortfolioCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: PortfolioCollectionCell.self)
    
    let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func awakeFromNib() {
        layout()
    }
    
    private func layout() {
        contentView.addSubview(nftImageView)
        nftImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
