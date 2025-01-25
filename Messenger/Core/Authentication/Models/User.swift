//
//  User.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import Foundation
import FirebaseFirestore


struct User: Codable, Hashable, Equatable {
    @DocumentID var userId: String?
    let fullname: String
    let email: String
    var profileImageUrl: String?
    
    var id: String {
        return userId ?? UUID().uuidString
    }
    
    var firstName: String {
        let components = fullname.components(separatedBy: " ")
        return components.first ?? fullname
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
