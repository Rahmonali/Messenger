//
//  NewMessageViewModel.swift
//  Messenger
//
//  Created by Rahmonali on 25/01/25.
//

import UIKit

class NewMessageViewModel {
    private var allUsers = [User]()
    var filteredUsers = [User]()
    var searchText: String = "" {
        didSet {
            filterUsers()
        }
    }

    var onUsersUpdated: (() -> Void)?

    func fetchUsers() {
        Task {
            do {
                let currentUser = try await AuthService.shared.fetchCurrentUser()
                self.allUsers = try await UserService.shared.fetchUsers()
                    .filter { $0.userId != currentUser.userId }
                self.filteredUsers = allUsers
                await MainActor.run {
                    self.onUsersUpdated?()
                }
            } catch {
                print("DEBUG: Failed to fetch users - \(error.localizedDescription)")
            }
        }
    }

    private func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter { $0.fullname.lowercased().contains(searchText.lowercased()) }
        }
        onUsersUpdated?()
    }
}
