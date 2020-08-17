//
//  MyChatCell.swift
//  ChatApp
//
//  Created by Dan on 8/3/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class MyChatCell: UITableViewCell {
    
    @IBOutlet weak var lbName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(_ message: Messages) {
        lbName.text = message.content
    }
    
}
