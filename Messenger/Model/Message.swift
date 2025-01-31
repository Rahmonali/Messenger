//
//  Message.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

enum MessageSendType {
    case text(String)
    case image(UIImage)
    case location(latitude: Double, longitude: Double)
    case contact(name: String, phoneNumber: String)
}

enum ContentType {
    case text(String)
    case image(String)
    case location(latitude: Double, longitude: Double)
    case contact(name: String, phoneNumber: String)
}

struct Message: Codable, Hashable {
    @DocumentID var messageId: String?
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Timestamp
    var user: User?
    var read: Bool
    var imageUrl: String?
    var latitude: Double?
    var longitude: Double?
    var contactName: String?
    var contactPhoneNumber: String?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var chatPartnerId: String {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
    
    var isImageMessage: Bool {
        return imageUrl != nil
    }
    
    var contentType: ContentType {
        if let imageUrl = imageUrl {
            return .image(imageUrl)
        } else if let latitude = latitude, let longitude = longitude {
            return .location(latitude: latitude, longitude: longitude)
        } else if let contactName = contactName, let contactPhoneNumber = contactPhoneNumber {
            return .contact(name: contactName, phoneNumber: contactPhoneNumber)
        }
        return .text(text)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
}

struct Conversation: Identifiable, Hashable, Codable {
    @DocumentID var conversationId: String?
    let lastMessage: Message
    var firstMessageId: String?
    
    var id: String {
        return conversationId ?? NSUUID().uuidString
    }
}
