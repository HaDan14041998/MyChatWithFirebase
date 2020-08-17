//
//  UICollectionViewExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueReuseableCell<T: UICollectionViewCell>(cell: T.Type, for indexPath: IndexPath, handle:((T) -> Void)) -> UICollectionViewCell {
        if let cell = self.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T {
            handle(cell)
            return cell
        }
        
        return UICollectionViewCell()
    }
}
