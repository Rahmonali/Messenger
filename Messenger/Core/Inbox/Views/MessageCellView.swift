//
//  MessageCellView.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit
import FirebaseCore

class MessageCellView: UIView {
    
    private let profileImageView = CircularProfileImageView(size: .medium)
    private let fullnameLabel = makeLabel(textStyle: .subheadline, isBold: true, numberOfLines: 1)
    private let messageTextLabel = makeLabel(textStyle: .footnote, textColor: .gray, numberOfLines: 2)
    private let timestampLabel = makeLabel(textStyle: .footnote, textColor: .gray, numberOfLines: 1)
    
    private let readIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, messageTextLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var trailingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timestampLabel, chevronImageView])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(message: Message) {
        super.init(frame: .zero)
        setupView()
        configure(with: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Add subviews to container stack
        let leadingStack = UIStackView(arrangedSubviews: [readIndicator, profileImageView])
        leadingStack.axis = .horizontal
        leadingStack.spacing = 4
        leadingStack.alignment = .center
        leadingStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerStack.addArrangedSubview(leadingStack)
        containerStack.addArrangedSubview(messageStack)
        containerStack.addArrangedSubview(trailingStack)
        
        addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            readIndicator.widthAnchor.constraint(equalToConstant: 6),
            readIndicator.heightAnchor.constraint(equalToConstant: 6),
            
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    private func configure(with message: Message) {
        fullnameLabel.text = message.user?.fullname
        
        // Directly set the message text since it's not optional
        let messageText = message.isFromCurrentUser ? "You: \(message.text)" : message.text
        messageTextLabel.text = messageText
        
        // Configure the timestamp
        timestampLabel.text = message.timestamp.dateValue().timestampString()
        
        // Hide the read indicator if the message is read or is from the current user
        readIndicator.isHidden = message.read || message.isFromCurrentUser
    }
}


#Preview {
    MessageCellView(
        message: Message(messageId: "1", fromId: "rahmonali", toId: "abubakr", text: "Test message for you", timestamp: Timestamp(),
                         user: User(fullname: "Rahmonali Fatkhuddinov", email: "rahmonali@gmail.com", profileImageUrl: nil), read: false, imageUrl: nil))
}
