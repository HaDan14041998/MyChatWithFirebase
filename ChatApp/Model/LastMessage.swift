//
//  LastMessage.swift
//  ChatApp
//
//  Created by Dan on 8/13/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class LastMessage: Codable {
    var lastMessage: String?
    var timestamp: Double?
    var uidA: String?
    var unreadA: Int?
    var uidB: String?
    var unreadB: Int?
    
    init(lastMessage: String?, timestamp: Double?, uidA: String?, uidB: String?, unreadB: Int?) {
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.uidA = uidA
        self.uidB = uidB
        self.unreadB = unreadB
    }
    
    init(lastMessage: String?, timestamp: Double?, uidA: String?, uidB: String?, unreadA: Int?, unreadB: Int?) {
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.uidA = uidA
        self.uidB = uidB
        self.unreadB = unreadB
        self.unreadA = unreadA
    }
}
