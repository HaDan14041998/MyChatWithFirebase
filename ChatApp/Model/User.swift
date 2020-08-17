//
//  User.swift
//  ChatApp
//
//  Created by Dan on 7/22/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class User: Codable {
    var id: String?
    var name: String?
    var email: String?
    var profileImage: String?
    var timestamp: Double?
    var isOnline: Bool?
    
    init(id: String?, name: String?, email: String?, profileImage: String?, timestamp: Double?, isOnline: Bool?) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.timestamp = timestamp
        self.isOnline = isOnline
    }
    
    init(id: String?, name: String?, profileImage: String? ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
    }

}


