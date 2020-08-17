//
//  UIViewControllerExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension UIViewController {
    func push<T: UIViewController>(storyBoard: String?, type: T.Type, bundle: Bundle? = nil, handle: ((T?) -> Void)) {
        if let viewController = UIStoryboard(name: storyBoard!, bundle: bundle).instantiateViewController(identifier: T.className) as? T {
            handle(viewController)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    static func initFromNib() -> Self {
        func instanceFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: self), bundle: nil)
        }
        return instanceFromNib()
    }
}
