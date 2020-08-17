//
//  UserCollectionViewCell.swift
//  ChatApp
//
//  Created by Dan on 7/22/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var onlineView: UIView!
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func fill(data: User){
        self.nameUserLabel.text = data.name
        guard let profileImageURL = data.profileImage  else { return }
        let url = URL(string: profileImageURL)
        guard let data1 = try? Data(contentsOf: url!) else { return }
        self.userImageView.image = UIImage(data: data1)
        guard let isOnline = data.isOnline else { return }
        if !isOnline {
            onlineView.backgroundColor = UIColor.lightGray
        }
    }
    
}
