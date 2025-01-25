//
//  CircularProfileImageView.swift
//  Messenger
//
//  Created by Rahmonali on 25/01/25.
//

import UIKit

class CircularProfileImageView: UIImageView {
    init(size: ProfileImageSize) {
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = size.dimension / 2
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size.dimension),
            self.heightAnchor.constraint(equalToConstant: size.dimension)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with imageUrl: String?) {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            //self.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            self.image = UIImage(systemName: "person.circle.fill")
            self.tintColor = UIColor.systemGray4
        }
    }
}
