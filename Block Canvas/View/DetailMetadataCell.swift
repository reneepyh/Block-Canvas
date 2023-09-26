//
//  DetailPageCell.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/26.
//

import UIKit

class DetailMetadataCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailMetadataCell.self)
    
    private let containerView = UIStackView()
    private let cellView = DetailMetadataCellView()
    let detailView = CustomDetailView()
    
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
        detailView.isHidden = true
        containerView.axis = .vertical
        
        contentView.addSubview(containerView)
        containerView.addArrangedSubview(cellView)
        containerView.addArrangedSubview(detailView)
        
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.top.equalTo(contentView.snp.top)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
}

extension DetailMetadataCell {
    var isDetailViewHidden: Bool {
        return detailView.isHidden
    }
    
    func showDetailView() {
        detailView.isHidden = false
    }
    
    func hideDetailView() {
        detailView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isDetailViewHidden, selected {
            showDetailView()
        } else {
            hideDetailView()
        }
        print("----------------------\(isDetailViewHidden)")
        print("=======================\(selected)")
    }
}
