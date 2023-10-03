//
//  DetailMetadataInfoCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/28.
//

import UIKit

class DetailMetadataInfoCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailMetadataInfoCell.self)
    
    private let titleFieldLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "Title"
        label.textColor = .secondaryBlur
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    private let artistFieldLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "Artist"
        label.textColor = .secondaryBlur
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    private let contractFieldLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "Contract"
        label.textColor = .secondaryBlur
        return label
    }()
    
    let contractLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .primary
        selectionStyle = .none
        addSubview(titleFieldLabel)
        titleFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(16)
            make.leading.equalTo(snp.leading).offset(16)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(16)
            make.leading.equalTo(snp.centerX).offset(-60)
            make.trailing.equalTo(snp.trailing).offset(-16)
        }
        
        addSubview(artistFieldLabel)
        artistFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(snp.leading).offset(16)
        }
        
        addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(snp.centerX).offset(-60)
            make.trailing.equalTo(snp.trailing).offset(-16)
        }
        
        addSubview(contractFieldLabel)
        contractFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(artistFieldLabel.snp.bottom).offset(16)
            make.leading.equalTo(snp.leading).offset(16)
        }
        
        addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.equalTo(contractFieldLabel.snp.top)
            make.leading.equalTo(snp.centerX).offset(-60)
            make.trailing.equalTo(snp.trailing).offset(-16)
            make.bottom.equalTo(snp.bottom).offset(-32)
        }
    }
}
