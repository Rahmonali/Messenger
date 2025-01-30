//
//  ChatMessageCell.swift
//  Messenger
//
//  Created by Rahmonali on 28/01/25.
//

import UIKit
import Kingfisher

class ChatMessageCell: UITableViewCell {
    
    static let identifier = "ChatMessageCell"
    private let messageLabel = makeLabel(textStyle: .subheadline, textColor: .white, textAlignment: .left, numberOfLines: 0)
    private let profileImageView = CircularProfileImageView(size: .xxSmall)
    
    private let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 8
        return stack
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(horizontalStack)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        leadingConstraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        trailingConstraint = horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            leadingConstraint,
            trailingConstraint,
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            messageImageView.widthAnchor.constraint(equalToConstant: 200),
            messageImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
        ])
    }
    
    func configure(with message: Message, user: User) {
        resetCell()
        
        switch message.contentType {
        case .text(let text):
            configureTextMessage(text: text)
        case .image(let imageUrl):
            configureImageMessage(imageUrl: imageUrl)
        }
        
        if message.isFromCurrentUser {
            configureOutgoingMessage()
        } else {
            configureIncomingMessage(user: user)
        }
    }
    
    private func configureTextMessage(text: String) {
        bubbleView.isHidden = false
        messageLabel.text = text
        messageImageView.isHidden = true
    }
    
    private func configureImageMessage(imageUrl: String) {
        bubbleView.isHidden = true
        messageImageView.isHidden = false
        
        if let url = URL(string: imageUrl) {
            messageImageView.kf.setImage(with: url)
        }
    }
    
    private func configureOutgoingMessage() {
        bubbleView.backgroundColor = .systemGreen
        profileImageView.isHidden = true
        
        horizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if messageImageView.isHidden {
            horizontalStack.addArrangedSubview(UIView())
            horizontalStack.addArrangedSubview(bubbleView)
        } else {
            horizontalStack.addArrangedSubview(UIView())
            horizontalStack.addArrangedSubview(messageImageView)
        }
        
        leadingConstraint.constant = 50
        trailingConstraint.constant = -8
    }
    
    private func configureIncomingMessage(user: User) {
        bubbleView.backgroundColor = .systemBlue
        profileImageView.isHidden = false
        profileImageView.configure(with: user.profileImageUrl)
        
        horizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        horizontalStack.addArrangedSubview(profileImageView)
        
        if messageImageView.isHidden {
            horizontalStack.addArrangedSubview(bubbleView)
        } else {
            horizontalStack.addArrangedSubview(messageImageView)
        }
        
        horizontalStack.addArrangedSubview(UIView())
        
        leadingConstraint.constant = 8
        trailingConstraint.constant = -50
    }
    
    private func resetCell() {
        messageLabel.text = nil
        messageImageView.image = nil
        messageImageView.isHidden = true
        bubbleView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}
