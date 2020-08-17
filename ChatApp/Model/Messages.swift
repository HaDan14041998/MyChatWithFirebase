//
//  Messages.swift
//  ChatApp
//
//  Created by Dan on 7/22/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class Messages: Codable {
    var fromID: String?
    var timeStamp: Double?
    var content: String?
    var toID: String?
    var imageUrl: String?
    
    init(_ content: String, fromID: String?, toID: String, timeStamp: Double) {
        self.content = content
        self.fromID = fromID
        self.toID = toID
        self.timeStamp = timeStamp
    }

}

