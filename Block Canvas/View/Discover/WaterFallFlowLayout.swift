//
//  WaterFallFlowLayout.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/24.
//

import UIKit

protocol WaterFallLayoutDelegate: NSObjectProtocol {
    func waterFlowLayout(_ waterFlowLayout: WaterFallFlowLayout, itemHeight indexPath: IndexPath) -> CGFloat
}

class WaterFallFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: WaterFallLayoutDelegate?
    
    var cols = 2
    
    fileprivate lazy var layoutAttributeArray: [UICollectionViewLayoutAttributes] = []
    
    fileprivate lazy var yArray: [CGFloat] = Array(repeating: self.sectionInset.top, count: cols)
    
    fileprivate var maxHeight: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        
        let itemWidth = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing * CGFloat(cols - 1)) / CGFloat(cols)
        
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        
        var minHeightIndex = 0
        
        for index in 0 ..< itemCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let itemHeight = delegate?.waterFlowLayout(self, itemHeight: indexPath)
            
            let value = yArray.min()
            
            minHeightIndex = yArray.firstIndex(of: value!)!
            
            var itemY = yArray[minHeightIndex]
            
            if index >= cols {
                itemY += minimumInteritemSpacing
            }
            
            let itemX = sectionInset.left + (itemWidth + minimumInteritemSpacing) * CGFloat(minHeightIndex)
            
            attr.frame = CGRect(x: itemX, y: itemY, width: itemWidth, height: CGFloat(itemHeight!))
            
            layoutAttributeArray.append(attr)
            
            yArray[minHeightIndex] = attr.frame.maxY
        }
        maxHeight = yArray.max()! + sectionInset.bottom
        
    }
    
    func clearCache() {
        layoutAttributeArray.removeAll()
        yArray = Array(repeating: self.sectionInset.top, count: cols)
    }

}

extension WaterFallFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributeArray.filter {
            $0.frame.intersects(rect)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.bounds.width, height: maxHeight)
    }
}
