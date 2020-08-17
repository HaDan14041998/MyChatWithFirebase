//
//  NSObjectsExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
