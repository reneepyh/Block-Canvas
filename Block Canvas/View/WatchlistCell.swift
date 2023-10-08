//
//  watchlistCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/21.
//

import UIKit
import SnapKit

class WatchlistCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: WatchlistCell.self)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let hiddenOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor(hex: "192200", alpha: 0.5)
        return overlay
    }()
    
    let hiddenImageView: UIImageView = {
        let overlay = UIImageView()
        overlay.image = UIImage(systemName: "eye.slash.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
        return overlay
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        contentView.addSubview(hiddenOverlay)
        hiddenOverlay.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        contentView.addSubview(hiddenImageView)
        hiddenImageView.snp.makeConstraints { make in
            make.centerX.equalTo(imageView.snp.centerX)
            make.centerY.equalTo(imageView.snp.centerY)
        }
    }
}
