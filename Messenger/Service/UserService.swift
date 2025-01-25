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
    
    var currentUser: User?
    
    static let shared = UserService()
    
    private init() {
        Task { try await fetchCurrentUser() }
    }

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
    
    
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await FirestoreConstants.UsersCollection.document(uid).getDocument()
        self.currentUser = try snapshot.data(as: User.self)
    }
    
    private func mapUsers(fromSnapshot snapshot: QuerySnapshot, currentUid: String) -> [User] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: User.self) })
            .filter({ $0.id !=  currentUid })
    }
}
