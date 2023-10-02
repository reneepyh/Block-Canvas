//
//  MJRefreshWrapper.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/2.
//

import UIKit
import MJRefresh

extension UICollectionView {

    func addRefreshHeader(refreshingBlock: @escaping () -> Void) {
        mj_header = MJRefreshNormalHeader(refreshingBlock: refreshingBlock)
    }

    func endHeaderRefreshing() {
        mj_header?.endRefreshing()
    }

    func beginHeaderRefreshing() {
        mj_header?.beginRefreshing()
    }
}

