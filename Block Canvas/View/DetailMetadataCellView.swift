//
//  CustomDetailCellView.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/26.
//

import UIKit
import SnapKit

class DetailMetadataCellView: UIView {
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .tertiary
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        metadataLabel.text = "Metadata"
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .primary
        addSubview(metadataLabel)
        metadataLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(16)
            make.leading.equalTo(snp.leading).offset(12)
            make.trailing.equalTo(snp.trailing).offset(-12)
            make.bottom.equalTo(snp.bottom)
        }
    }
}

class CustomDetailView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    let contractLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .primary
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(12)
            make.leading.equalTo(snp.leading).offset(12)
            make.trailing.equalTo(snp.trailing).offset(-12)
        }
        
        addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(snp.leading).offset(12)
            make.trailing.equalTo(snp.trailing).offset(-12)
        }
        
        addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(12)
            make.leading.equalTo(snp.leading).offset(12)
            make.trailing.equalTo(snp.trailing).offset(-12)
            make.bottom.lessThanOrEqualTo(snp.bottom).offset(-12)
        }
    }
}
