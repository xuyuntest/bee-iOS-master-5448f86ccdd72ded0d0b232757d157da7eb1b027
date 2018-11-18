//
//  UICollectionViewFlowLayoutCentered.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

protocol UICollectionViewDelegateFlowLayoutCentered: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayoutCentered, pageChanged page: Int)
}

class UICollectionViewFlowLayoutCentered: UICollectionViewFlowLayout {

    var previousOffset: CGFloat    = 0
    var currentPage: Int           = 0 {
        didSet {
            guard let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayoutCentered else { return }
            guard let collection = self.collectionView else { return }
            delegate.collectionView(collection, layout: self, pageChanged: currentPage)
        }
    }

    override func prepare() {
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return CGPoint.zero
        }
        
        guard let itemsCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) else {
            return CGPoint.zero
        }
        
        if ((previousOffset > collectionView.contentOffset.x) && (velocity.x < 0)) {
            currentPage = max(currentPage - 1, 0)
        } else if ((previousOffset < collectionView.contentOffset.x) && (velocity.x > 0.0)) {
            currentPage = min(currentPage + 1, itemsCount - 1);
        }
        let itemEdgeOffset:CGFloat = (collectionView.frame.width - itemSize.width -  minimumLineSpacing * 2) / 2
        let updatedOffset: CGFloat = sectionInset.left + (itemSize.width + minimumLineSpacing) * CGFloat(currentPage) - (itemEdgeOffset + minimumLineSpacing)
        
        previousOffset = updatedOffset;
        
        return CGPoint(x: updatedOffset, y: proposedContentOffset.y);
    }
    
}
