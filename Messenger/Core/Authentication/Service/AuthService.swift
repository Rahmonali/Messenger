//
//  AuthService.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


final class AuthService {
    var userSession: FirebaseAuth.User?
    
    public static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { try await loadUserData() }
    }

    private let db = Firestore.firestore()
        
    func createUser(with userRequest: CreateUserRequest) async throws {
        let fullname = userRequest.fullname
        let email = userRequest.email
        let password = userRequest.password
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await uploadUserData(email: email, fullname: fullname, id: result.user.uid)
            try await loadUserData()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }

    public func signIn(with userRequest: LoginUserRequest) async throws {
        do {
            
            let result = try await Auth.auth().signIn(withEmail: userRequest.email, password: userRequest.password)
            self.userSession = result.user
            try await loadUserData()
        } catch {
            throw error
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        UserService.shared.currentUser = nil
    }

    public func forgotPassword(with email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
    
    private func uploadUserData(email: String, fullname: String, id: String) async throws {
        let user = User(fullname: fullname, email: email, profileImageUrl: nil)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.UsersCollection.document(id).setData(encodedUser)
    }
    
    func loadUserData() async throws {
        try await UserService.shared.fetchCurrentUser()
    }
}

// MARK: - Custom Error Enum
enum AuthServiceError: LocalizedError {
    case userCreationFailed
    case userNotFound
    case noCurrentUser
    
    var errorDescription: String? {
        switch self {
        case .userCreationFailed:
            return "Failed to create user. Please try again."
        case .userNotFound:
            return "User not found. Please try again."
        case .noCurrentUser:
            return "No currently signed-in user."
        }
    }
}
