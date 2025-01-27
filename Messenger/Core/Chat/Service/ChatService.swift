//
//  ChatService.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    
    let chatPartner: User
    private let fetchLimit = 50
    
    private var firestoreListener: ListenerRegistration?
    
    init(chatPartner: User) {
        self.chatPartner = chatPartner
    }
    
    func observeMessages(completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return } // TODO: have to put it inside dispatchqu if needed
        let chatPartnerId = chatPartner.id
        
        let query = FirestoreConstants.MessagesCollection
            .document(currentUid)
            .collection(chatPartnerId)
            .limit(toLast: fetchLimit)
            .order(by: "timestamp", descending: false)
        
        self.firestoreListener = query.addSnapshotListener { [weak self] snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap{ try? $0.document.data(as: Message.self) }
            
            for (index, message) in messages.enumerated() where message.fromId != currentUid {
                messages[index].user = self?.chatPartner
            }
            
            completion(messages)
        }
    }
    
    func sendMessage(type: MessageSendType) async throws {
        switch type {
        case .text(let messageText):
            uploadMessage(messageText)
        case .image(let uIImage):
//            let imageUrl = try await ImageUploader.uploadImage(image: uIImage, type: .message)
//            uploadMessage("Attachment: Image", imageUrl: imageUrl)
                // TODO: Break...
            break
        }
    }
    
    private func uploadMessage(_ messageText: String, imageUrl: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let currentUserRef = FirestoreConstants.MessagesCollection.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = FirestoreConstants.MessagesCollection.document(chatPartnerId).collection(currentUid)
        
        let recentCurrentUserRef = FirestoreConstants.MessagesCollection
            .document(currentUid)
            .collection("recent-messages")
            .document(chatPartnerId)
        
        let recentPartnerRef = FirestoreConstants.MessagesCollection
            .document(chatPartnerId)
            .collection("recent-messages")
            .document(currentUid)
        
        let messageId = currentUserRef.documentID
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            toId: chatPartnerId,
            text: messageText,
            timestamp: Timestamp(),
            read: false,
            imageUrl: imageUrl
        )
        var currentUserMessage = message
        currentUserMessage.read = true
        
        guard let encodedMessage = try? Firestore.Encoder().encode(message) else { return }
        guard let encodedMessageCopy = try? Firestore.Encoder().encode(currentUserMessage) else { return }
        
        currentUserRef.setData(encodedMessageCopy)
        chatPartnerRef.document(messageId).setData(encodedMessage)
        
        recentCurrentUserRef.setData(encodedMessageCopy)
        recentPartnerRef.setData(encodedMessage)
    }
    
    func updateMessageStatusIfNecessary(_ message: Message) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !message.read else { return }
                
        try await FirestoreConstants.MessagesCollection
            .document(uid)
            .collection("recent-messages")
            .document(message.chatPartnerId)
            .updateData(["read": true])
    }
    
    func removeListener() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
}
