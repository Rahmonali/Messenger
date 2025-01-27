//
//  MessageCell.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit

class MessageCell: UITableViewCell {

    static let identifier = "MessageCell"

    private let messageCellView = MessageCellView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(messageCellView)
        messageCellView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            messageCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            messageCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with message: Message) {
        messageCellView.configure(with: message)
    }
}
