//
//  UIButtonExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension UIButton {
    func setRadiusSetting() {
        self.layer.cornerRadius = 25.0
        self.layer.masksToBounds = true
    }
    
    func setBorderSetting() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = 25.0
    }
}

