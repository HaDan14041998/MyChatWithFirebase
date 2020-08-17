//
//  UserChat.swift
//  ChatApp
//
//  Created by Dan on 7/26/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserChat: Codable {
    var peerId: String?
    var name: String?
    var profileImage: String?
    var peerRef: String?
    var unread: Int?
    var lastMessage: String?
    var timestamp: Double?
    
    let uid = Auth.auth().currentUser?.uid
    
    init(name: String?, profileImage: String?, peer_ref: String?, timestamp: Double?) {
        self.name = name
        self.profileImage = profileImage
        self.peerRef = peer_ref
        self.timestamp = timestamp
    }
    
    init(userGroupChat: UserGroupChat, lastMessageChat: LastMessage) {
        self.name = userGroupChat.name
        self.peerRef = userGroupChat.peerRef
        self.profileImage = userGroupChat.profileImage
        self.lastMessage = lastMessageChat.lastMessage
        self.timestamp = lastMessageChat.timestamp
        if uid == lastMessageChat.uidA {
            self.unread = lastMessageChat.unreadA
            self.peerId = lastMessageChat.uidB
        } else {
            self.unread = lastMessageChat.unreadB
            self.peerId = lastMessageChat.uidA
        }
        
    }
}
 
