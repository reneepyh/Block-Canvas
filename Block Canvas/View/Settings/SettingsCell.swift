//
//  SettingsCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/30.
//

import UIKit
import SnapKit

class SettingsCell: UITableViewCell {
    static let reuseIdentifier = String(describing: SettingsCell.self)

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let settingsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .secondary
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .primary
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(18)
            make.leading.equalTo(contentView.snp.leading).offset(24)
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.bottom.equalTo(contentView.snp.bottom).offset(-18)
        }
        
        addSubview(settingsLabel)
        settingsLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.centerY.equalTo(iconImageView.snp.centerY)
        }
    }
}
