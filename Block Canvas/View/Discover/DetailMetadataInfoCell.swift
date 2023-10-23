//
//  DetailMetadataInfoCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/28.
//

import UIKit

protocol DetailMetadataInfoCellDelegate: AnyObject {
    func tokenTapped()
}

class DetailMetadataInfoCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailMetadataInfoCell.self)
    
    weak var delegate: DetailMetadataInfoCellDelegate?
    
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
    
    private let tokenFieldLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "Token"
        label.textColor = .secondaryBlur
        return label
    }()
    
    let tokenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.tertiary, for: .normal)
        button.setTitleColor(.tertiary, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.numberOfLines = 0
        button.contentHorizontalAlignment = .left
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.configuration = config
        return button
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
        contentView.addSubview(titleFieldLabel)
        titleFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalTo(contentView.snp.centerX).offset(-60)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
        
        contentView.addSubview(artistFieldLabel)
        artistFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
        }
        
        contentView.addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.centerX).offset(-60)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
        
        contentView.addSubview(tokenFieldLabel)
        tokenFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(artistFieldLabel.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
        }
        
        contentView.addSubview(tokenButton)
        tokenButton.snp.makeConstraints { make in
            make.top.equalTo(tokenFieldLabel.snp.top)
            make.leading.equalTo(contentView.snp.centerX).offset(-60)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-32)
        }
        
        tokenButton.addTarget(self, action: #selector(contractLabelTapped), for: .touchUpInside)
    }
    
    @objc func contractLabelTapped() {
        delegate?.tokenTapped()
    }
}
