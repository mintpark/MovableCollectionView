//
//  Extensions.swift
//  SelectableCollectionView
//
//  Created by Hayoung Park on 2020/04/25.
//  Copyright © 2020 Hayoung Park. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func scrollToSupplementaryView(ofKind kind: String, at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        self.layoutIfNeeded()
        if let layoutAttributes = self.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) {
            let viewOrigin = CGPoint(x: layoutAttributes.frame.origin.x, y: layoutAttributes.frame.origin.y)
            var resultOffset: CGPoint = self.contentOffset
            
            switch(scrollPosition) {
            case UICollectionView.ScrollPosition.top:
                resultOffset.y = viewOrigin.y - self.contentInset.top - 30
                
            case UICollectionView.ScrollPosition.left:
                resultOffset.x = viewOrigin.x - self.contentInset.left
                
            case UICollectionView.ScrollPosition.right:
                resultOffset.x = (viewOrigin.x - self.contentInset.left) - (self.frame.size.width - layoutAttributes.frame.size.width)
                
            case UICollectionView.ScrollPosition.bottom:
                resultOffset.y = (viewOrigin.y - self.contentInset.top) - (self.frame.size.height - layoutAttributes.frame.size.height)
                
            case UICollectionView.ScrollPosition.centeredVertically:
                resultOffset.y = (viewOrigin.y - self.contentInset.top) - (self.frame.size.height / 2 - layoutAttributes.frame.size.height / 2)
                
            case UICollectionView.ScrollPosition.centeredHorizontally:
                resultOffset.x = (viewOrigin.x - self.contentInset.left) - (self.frame.size.width / 2 - layoutAttributes.frame.size.width / 2)
            default:
                break;
            }
            self.scrollRectToVisible(CGRect(origin: resultOffset, size: self.frame.size), animated: animated)
        }
    }
}
