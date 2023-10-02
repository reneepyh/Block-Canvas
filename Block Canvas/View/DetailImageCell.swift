//
//  DetailImageCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/26.
//

import UIKit

class DetailImageCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailImageCell.self)
    
    let detailImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .justified
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
        contentView.addSubview(detailImageView)
        detailImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(500)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(detailImageView.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-60)
        }
    }
}
