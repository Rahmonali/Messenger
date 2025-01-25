//
//  Constants.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import Foundation
import Firebase

struct FirestoreConstants {
    static let Root = Firestore.firestore()
    
    static let UsersCollection = Root.collection("users")
    
    static let MessagesCollection = Root.collection("messages")
}


let heightTextField: CGFloat = 50
let heightButton: CGFloat = 48
