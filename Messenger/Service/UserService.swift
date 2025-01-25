//
//  UserService.swift
//  Messenger
//
//  Created by Rahmonali on 25/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class UserService {
    static let shared = UserService()
    private init() {}

    private let db = Firestore.firestore()
    
    func fetchUsers(limit: Int? = nil) async throws -> [User] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        let query = FirestoreConstants.UsersCollection
        
        if let limit {
            let snapshot = try await query.limit(to: limit).getDocuments()
            return mapUsers(fromSnapshot: snapshot, currentUid: currentUid)
        }
        
        let snapshot = try await query.getDocuments()
        return mapUsers(fromSnapshot: snapshot, currentUid: currentUid)
    }
    
    private func mapUsers(fromSnapshot snapshot: QuerySnapshot, currentUid: String) -> [User] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: User.self) })
            .filter({ $0.id !=  currentUid })
    }
}
