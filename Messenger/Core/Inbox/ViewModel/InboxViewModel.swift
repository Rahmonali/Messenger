//
//  InboxViewModel.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit
import FirebaseFirestore

class InboxViewModel {
    var recentMessages: [Message] = []
    var conversations: [Conversation] = []
    var user: User?
    var searchText: String = ""

    var filteredMessages: [Message] {
        if searchText.isEmpty {
            return recentMessages
        } else {
            return recentMessages.filter { message in
                guard let user = message.user else { return false }
                return user.fullname.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private var didCompleteInitialLoad = false
    private var firestoreListener: ListenerRegistration?

    init() {
        setupSubscribers()
        observeRecentMessages()
    }
    
    private func setupSubscribers() {
        InboxService.shared.documentChangesDidUpdate = { [weak self] changes in
            guard let self = self, !changes.isEmpty else { return }

            if !self.didCompleteInitialLoad {
                Task {
                   self.loadInitialMessages(fromChanges: changes)
                }
            } else {
                Task {
                    self.updateMessages(fromChanges: changes)
                }
            }
        }
    }
    
    
    func observeRecentMessages() {
        InboxService.shared.observeRecentMessages()
    }

    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        self.recentMessages = changes.compactMap{ try? $0.document.data(as: Message.self) }
        
        for i in 0 ..< recentMessages.count {
            let message = recentMessages[i]

            UserService.fetchUser(withUid: message.chatPartnerId) { [weak self] user in
                guard let self else { return }
                self.recentMessages[i].user = user
                
                if i == self.recentMessages.count - 1 {
                    self.didCompleteInitialLoad = true
                }
            }
        }
    }

    
    private func updateMessages(fromChanges changes: [DocumentChange]) {
        for change in changes {
            if change.type == .added {
                self.createNewConversation(fromChange: change)
            } else if change.type == .modified {
                self.updateMessagesFromExisitingConversation(fromChange: change)
            }
        }
    }
    
    private func createNewConversation(fromChange change: DocumentChange) {
        guard var message = try? change.document.data(as: Message.self) else { return }
        
        UserService.fetchUser(withUid: message.chatPartnerId) { user in
            message.user = user
            self.recentMessages.insert(message, at: 0)
        }
    }
    
    private func updateMessagesFromExisitingConversation(fromChange change: DocumentChange) {
        guard var message = try? change.document.data(as: Message.self) else { return }
        guard let index = self.recentMessages.firstIndex(where: {
            $0.user?.id ?? "" == message.chatPartnerId
        }) else { return }
        guard let user = self.recentMessages[index].user else { return }
        message.user = user
        
        self.recentMessages.remove(at: index)
        self.recentMessages.insert(message, at: 0)
    }
    
    func deleteMessage(_ message: Message) async throws {
        do {
            recentMessages.removeAll(where: { $0.id == message.id })
            try await InboxService.deleteMessage(message)
        } catch {
            // TODO: If deletion fails add message back at original index
        }
    }
}
