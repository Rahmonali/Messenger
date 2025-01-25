//
//  NewMessageUserTableViewCell.swift
//  Messenger
//
//  Created by Rahmonali on 25/01/25.
//

import UIKit

class NewMessageUserTableViewCell: UITableViewCell {
    static let identifier = "NewMessageUserTableViewCell"
    private let profileImageView: CircularProfileImageView = CircularProfileImageView(size: .small)

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.fullname
        profileImageView.configure(with: user.profileImageUrl)
    }
}



#Preview {
    NewMessageUserTableViewCell()
}
