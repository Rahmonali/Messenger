//
//  AuthService.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class AuthService {
    
    public static let shared = AuthService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    public func registerUser(with userRequest: RegisterUserRequest) async throws {
        let username = userRequest.username
        let email = userRequest.email
        let password = userRequest.password
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userUID = result.user.uid
            
            let userData: [String: Any] = [
                "username": username,
                "email": email
            ]
            
            try await db.collection("users").document(userUID).setData(userData)
        } catch {
            throw error
        }
    }
    
    public func signIn(with userRequest: LoginUserRequest) async throws {
        do {
            try await Auth.auth().signIn(withEmail: userRequest.email, password: userRequest.password)
        } catch {
            throw error
        }
    }
    
    public func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw error
        }
    }
    
    public func forgotPassword(with email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
    
    public func fetchUser() async throws -> User {
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw AuthServiceError.noCurrentUser
        }
        
        do {
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            guard let data = snapshot.data(),
                  let username = data["username"] as? String,
                  let email = data["email"] as? String else {
                throw AuthServiceError.userNotFound
            }
            return User(username: username, email: email, userUID: userUID)
        } catch {
            throw error
        }
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
