//
//  UILabelExtension.swift
//  ChatApp
//
//  Created by Dan on 7/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension UILabel {
    func setMutltiText(a: String, b: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: a, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSMutableAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.65)])
        let attributedSubtermsText = NSMutableAttributedString(string: b, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSMutableAttributedString.Key.foregroundColor: UIColor.black])
        attributedText.append(attributedSubtermsText)
        self.attributedText = attributedText
        return attributedText
    }
}
