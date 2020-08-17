//
//  MessagesTableViewCell.swift
//  ChatApp
//
//  Created by Dan on 7/22/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessagesTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var messagesTitleLabel: UILabel!
    @IBOutlet weak var timeCurrentMessageLabel: UILabel!
    @IBOutlet weak var onlineView: BorderView!
    @IBOutlet weak var unreadView: BorderView!
    @IBOutlet weak var unreadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fillData(data: UserChat) {
        guard let peer_id = data.peerId else { return }
        Firestores.documentUser.whereField("id", isEqualTo: peer_id).getDocuments { (authResult, err) in
            if let err = err {
                print (err.localizedDescription)
            }
            if let result = authResult {
                for document in result.documents {
                    let dataUser = document.data()
                    guard let isOnline = dataUser["isOnline"] as? Bool else { return }
                    if !isOnline {
                        self.onlineView.backgroundColor = UIColor.lightGray
                    }
                }
            }

        }
        
        self.nameUserLabel.text = data.name
        if let profileImageURL = data.profileImage {
            let url = URL(string: profileImageURL)
            let dataImage = try? Data(contentsOf: url!)
            self.userImageView.image = UIImage(data: dataImage!)
        }
        self.messagesTitleLabel.text = data.lastMessage
        let currentDateTime = Date()
        if let timestamp = data.timestamp {
            if currentDateTime.convertDate() == Date(timeIntervalSince1970: timestamp ).convertDate() {
                self.timeCurrentMessageLabel.text = Date(timeIntervalSince1970: timestamp).convert()
            } else {
                self.timeCurrentMessageLabel.text = Date(timeIntervalSince1970: timestamp).convertDayCalendar()
            }
        }
        let unreadCount = data.unread 
        let unreadString = String(describing: unreadCount ?? 0)
        if unreadCount != 0 {
            self.unreadView.isHidden = false
            self.unreadLabel.text = unreadString
            self.nameUserLabel.font = .boldSystemFont(ofSize: 17)
        } else {
            self.nameUserLabel.font = .systemFont(ofSize: 17)
            self.unreadView.isHidden = true
        }
    }
}
