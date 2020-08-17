//
//  Constraint.swift
//  ChatApp
//
//  Created by Dan on 7/27/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Firestores {
    static var documentUser = Firestore.firestore().collection("User")
    static var documentThreads = Firestore.firestore().collection("Threads")
}
