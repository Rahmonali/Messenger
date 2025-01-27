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
    private let nameLabel = makeLabel(textStyle: .headline, isBold: true, numberOfLines: 1)
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let HStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(HStack)
        
        HStack.addArrangedSubview(profileImageView)
        HStack.addArrangedSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            HStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            HStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            HStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            HStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
