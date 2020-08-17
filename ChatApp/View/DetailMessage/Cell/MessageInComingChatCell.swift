//
//  MessageChatCell.swift
//  ChatApp
//
//  Created by Dan on 7/27/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessageInComingChatCell: UITableViewCell {
    @IBOutlet weak var viewChat: BorderChatView!
    @IBOutlet weak var userImageChat: ImageLoader!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var chatLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillData(data: Messages) {
        self.chatLabel.text = data.content
        guard let fromID = data.fromID else { return }
        Firestores.documentUser.whereField("id", isEqualTo: fromID).getDocuments { (result, err) in
            guard let result = result else { return }
            for document in result.documents {
                let data = document.data()
                guard let profileImageURL = data["profileImage"] else { return }
                let url = URL(string: profileImageURL as! String)
                self.userImageChat.loadImageWithUrl(url!)
            }
        }
    }
    
}
