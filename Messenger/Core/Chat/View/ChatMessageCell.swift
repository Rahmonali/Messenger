//
//  ChatMessageCell.swift
//  Messenger
//
//  Created by Rahmonali on 28/01/25.
//

import UIKit

class ChatMessageCell: UITableViewCell {

    static let identifier = "ChatMessageCell"

    private let messageLabel = makeLabel(textStyle: .subheadline, textColor: .white, textAlignment: .left, numberOfLines: 0)
    private let profileImageView: CircularProfileImageView = CircularProfileImageView(size: .xxSmall)

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

    // MARK: - Constraints
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupViews() {
    
        bubbleView.addSubview(messageLabel)
        horizontalStack.addArrangedSubview(profileImageView)
        horizontalStack.addArrangedSubview(bubbleView)
        contentView.addSubview(horizontalStack)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
    }

    private func setupConstraints() {
        leadingConstraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        trailingConstraint = horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            leadingConstraint,
            trailingConstraint
        ])
    }

    func configure(with message: Message, user: User) {
        messageLabel.text = message.text

        if message.isFromCurrentUser {
            configureOutgoingMessage()
        } else {
            configureIncomingMessage(user: user)
        }
    }

    private func configureOutgoingMessage() {
        bubbleView.backgroundColor = .systemGreen
        profileImageView.isHidden = true

        horizontalStack.arrangedSubviews.forEach { horizontalStack.removeArrangedSubview($0) }
        horizontalStack.addArrangedSubview(UIView())
        horizontalStack.addArrangedSubview(bubbleView)

        leadingConstraint.constant = 50
        trailingConstraint.constant = -8
    }

    private func configureIncomingMessage(user: User) {
        bubbleView.backgroundColor = .systemBlue
        profileImageView.isHidden = false
        profileImageView.configure(with: user.profileImageUrl)

        horizontalStack.arrangedSubviews.forEach { horizontalStack.removeArrangedSubview($0) }
        horizontalStack.addArrangedSubview(profileImageView)
        horizontalStack.addArrangedSubview(bubbleView)

        leadingConstraint.constant = 8
        trailingConstraint.constant = -50
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        horizontalStack.arrangedSubviews.forEach { horizontalStack.removeArrangedSubview($0) }
    }
}
