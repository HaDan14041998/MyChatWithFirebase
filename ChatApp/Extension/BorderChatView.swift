//
//  BorderChatView.swift
//  ChatApp
//
//  Created by Dan on 8/3/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class BorderChatView: UIView {
    override func awakeFromNib() {
        self.layoutIfNeeded()
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}
