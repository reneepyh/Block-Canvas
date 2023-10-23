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
    
    let walletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let walletNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .secondary
        textField.font = .boldSystemFont(ofSize: 16)
        return textField
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .tertiary
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        walletImageView.image = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .primary
        contentView.addSubview(walletImageView)
        walletImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(14)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(walletNameTextField)
        walletNameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(walletImageView.snp.bottom)
            make.leading.equalTo(walletImageView.snp.trailing).offset(8)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
        
        contentView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameTextField.snp.bottom).offset(8)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
        
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-12)
        }
        
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.bottom.equalTo(walletImageView.snp.bottom)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
    }
    
}
