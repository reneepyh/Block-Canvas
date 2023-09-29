//
//  DetailPageCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/26.
//

import UIKit

class DetailMetadataCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailMetadataCell.self)
    
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .tertiary
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiary
        return view
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
        addSubview(metadataLabel)
        metadataLabel.text = "Metadata"
        metadataLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(16)
            make.leading.equalTo(snp.leading).offset(16)
            make.bottom.equalTo(snp.bottom)
        }
        
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(16)
            make.trailing.equalTo(snp.trailing).offset(-16)
        }
        
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalTo(metadataLabel.snp.leading)
            make.trailing.equalTo(arrowImageView.snp.trailing)
            make.bottom.equalTo(metadataLabel.snp.top).offset(-8)
        }
    }
}
