//
//  FirebaseStorage.swift
//  ChatApp
//
//  Created by Dan on 7/28/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import FirebaseStorage

struct FirebaseStorages {
    static var storageRef = Storage.storage().reference(forURL: "gs://loginchatfirebase-99380.appspot.com").child("profile")
    static var storageMessageRef = Storage.storage().reference(forURL: "gs://loginchatfirebase-99380.appspot.com").child("message")
}

