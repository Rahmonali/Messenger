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
    
    var currentUser: User? {
        didSet {
            print("DEBUG: DID set current user.......")
            currentUserDidChange?(currentUser) // Notify when currentUser changes
        }
    }
    
    var currentUserDidChange: ((User?) -> Void)?
    
    static let shared = UserService()
    
    init() {
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
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        FirestoreConstants.UsersCollection.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else {
                print("DEBUG: Failed to map user")
                return
            }
            completion(user)
        }
    }
    
    func updateUserFullname(_ fullname: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.noCurrentUser
        }
        let userDocument = db.collection("users").document(userId)
        try await userDocument.updateData(["fullname": fullname])
        let snapshot = try await userDocument.getDocument()
        currentUser = try snapshot.data(as: User.self)
    }
    
    private func mapUsers(fromSnapshot snapshot: QuerySnapshot, currentUid: String) -> [User] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: User.self) })
            .filter({ $0.id !=  currentUid })
    }
    
    func updateUserProfileImageUrl(_ imageUrl: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.noCurrentUser
        }
        let userDocument = db.collection("users").document(userId)
        try await userDocument.updateData(["profileImageUrl": imageUrl])
        let snapshot = try await userDocument.getDocument()
        currentUser = try snapshot.data(as: User.self)
    }
    
    enum UserServiceError: Error {
        case noCurrentUser
    }
}
