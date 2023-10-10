//
//  MJRefreshWrapper.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/2.
//

import UIKit
import MJRefresh

extension UICollectionView {
    private static var _mjRefreshConfig: Void {
        MJRefreshConfig.default.languageCode = "en"
    }
    
    // Ensure the static property is accessed, thus setting the configuration
    private func configureMJRefresh() {
        _ = UICollectionView._mjRefreshConfig
    }
    
    var isHeaderHidden: Bool {
        get {
            return mj_header?.isHidden ?? true
        }
        set {
            if let header = mj_header {
                header.isHidden = newValue
            }
        }
    }
    
    var isFooterHidden: Bool {
        get {
            return mj_footer?.isHidden ?? true
        }
        set {
            if let footer = mj_footer {
                footer.isHidden = newValue
            }
        }
    }
    
    func addRefreshHeader(refreshingBlock: @escaping () -> Void) {
        configureMJRefresh()
        mj_header = MJRefreshNormalHeader(refreshingBlock: refreshingBlock)
    }
    
    func endHeaderRefreshing() {
        configureMJRefresh()
        mj_header?.endRefreshing()
    }
    
    func addRefreshFooter(refreshingBlock: @escaping () -> Void) {
        configureMJRefresh()
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: refreshingBlock)
        footer.setTitle("", for: .idle)
        mj_footer = footer
    }
    
    func endFooterRefreshing() {
        configureMJRefresh()
        mj_footer?.endRefreshing()
    }
    
    func endWithNoMoreData() {
        configureMJRefresh()
        mj_footer?.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        mj_footer?.resetNoMoreData()
    }
}
