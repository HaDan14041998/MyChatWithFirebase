//
//  BorderView.swift
//  ChatApp
//
//  Created by Dan on 7/30/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class BorderView: UIView {

    override func awakeFromNib() {
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.width / 2.0
        layer.masksToBounds = true
    }

}
