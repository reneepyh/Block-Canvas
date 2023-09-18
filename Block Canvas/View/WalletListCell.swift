//
//  WalletListCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import SnapKit

class WalletListCell: UITableViewCell {

    static let reuseIdentifier = String(describing: WalletListCell.self)
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .systemGray2
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.left.equalTo(contentView.snp.left).offset(16)
            make.right.equalTo(contentView.snp.right).offset(-16)
        }
        
        contentView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView.snp.left).offset(16)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-12)
        }
    }

}
