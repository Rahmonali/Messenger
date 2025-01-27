//
//  InboxService.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class InboxService {
    static let shared = InboxService()
    
    private(set) var documentChanges: [DocumentChange] = [] {
        didSet {
            documentChangesDidUpdate?(documentChanges) // Notify observers
        }
    }
    
    var documentChangesDidUpdate: (([DocumentChange]) -> Void)?
    
    private var firestoreListener: ListenerRegistration?
    
    func observeRecentMessages() {
        DispatchQueue.main.async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let query = FirestoreConstants.MessagesCollection
                .document(uid)
                .collection("recent-messages")
                .order(by: "timestamp", descending: true)
            
            self.firestoreListener = query.addSnapshotListener { snapshot, _ in
                guard let changes = snapshot?.documentChanges.filter({
                    $0.type == .added || $0.type == .modified
                }) else { return }
                
                self.documentChanges = changes
            }
        }
    }
    
    static func deleteMessage(_ message: Message) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = message.chatPartnerId
        
        let snapshot = try await FirestoreConstants.MessagesCollection.document(uid).collection(chatPartnerId).getDocuments()
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for doc in snapshot.documents {
                group.addTask {
                    try await FirestoreConstants.MessagesCollection
                        .document(uid)
                        .collection(chatPartnerId)
                        .document(doc.documentID)
                        .delete()
                }
            }
            
            group.addTask {
                try await FirestoreConstants.MessagesCollection
                    .document(uid)
                    .collection("recent-messages")
                    .document(chatPartnerId)
                    .delete()
            }
        }
    }
    
    func reset() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
        self.documentChanges.removeAll()
    }
}
