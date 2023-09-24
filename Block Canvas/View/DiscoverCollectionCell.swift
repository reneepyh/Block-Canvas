//
//  TrendingCollectionCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit

class DiscoverCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: DiscoverCollectionCell.self)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
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
            make.width.equalTo(170)
            make.height.equalTo(imageView.snp.width).multipliedBy(1.4)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.equalTo(contentView.snp.leading)
        }
    }
}
