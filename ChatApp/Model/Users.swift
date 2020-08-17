//
//  Users.swift
//  ChatApp
//
//  Created by Dan on 7/29/20.
//  Copyright © 2020 Dan. All rights reserved.
//


import UIKit

class UsersSetData {
    var id: String?
    var name: String?
    var email: String?
    var profileImage: String?
    var timestamp: NSNumber?

    init(id: String, name: String, email: String, profileImage: String, timestamp: NSNumber) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.timestamp = timestamp
    }

    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["email"] = email
        dictionary["profileImage"] = profileImage
        dictionary["timestamp"] = timestamp
        return dictionary
    }

}
