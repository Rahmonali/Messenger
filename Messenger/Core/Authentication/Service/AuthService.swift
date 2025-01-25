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
    public static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()
        
    func createUser(with userRequest: CreateUserRequest) async throws {
        let fullname = userRequest.fullname
        let email = userRequest.email
        let password = userRequest.password
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await uploadUserData(email: email, fullname: fullname, id: result.user.uid)
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
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

    public func fetchCurrentUser() async throws -> User {
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw AuthServiceError.noCurrentUser
        }

        do {
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            guard let data = snapshot.data(),
                  let fullname = data["fullname"] as? String,
                  let email = data["email"] as? String else {
                throw AuthServiceError.userNotFound
            }
            return User(userId: userUID, fullname: fullname, email: email)
        } catch {
            throw error
        }
    }
    
    private func uploadUserData(email: String, fullname: String, id: String) async throws {
        let user = User(fullname: fullname, email: email, profileImageUrl: nil)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.UsersCollection.document(id).setData(encodedUser)
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
