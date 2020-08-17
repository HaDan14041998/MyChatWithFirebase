//
//  UITableViewExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(cell: T.Type, for indexPath: IndexPath, handle:((T) -> Void)) -> UITableViewCell {
        if let cell = self.dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? T {
            handle(cell)
            return cell
        }
        
        return UITableViewCell()
    }
}
