//
//  ChatMessageCell.swift
//  Messenger
//
//  Created by Rahmonali on 28/01/25.
//

import UIKit
import Kingfisher
import MapKit

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
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 10
        map.isUserInteractionEnabled = false
        return map
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
        contentView.addSubview(mapView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            mapView.widthAnchor.constraint(equalToConstant: 200),
            mapView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configure(with message: Message, user: User) {
        resetCell()
        
        switch message.contentType {
        case .text(let text):
            configureTextMessage(text: text)
        case .image(let imageUrl):
            configureImageMessage(imageUrl: imageUrl)
        case .location(let latitude, let longitude):
            configureLocationMessage(latitude: latitude, longitude: longitude)
        case .contact(name: let name, phoneNumber: let phoneNumber):
            configureContactMessage(name: name, phoneNumber: phoneNumber)
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
    
    private func configureLocationMessage(latitude: Double, longitude: Double) {
        mapView.isHidden = false
        bubbleView.isHidden = true
        messageImageView.isHidden = true
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    private func configureContactMessage(name: String, phoneNumber: String) {
        bubbleView.isHidden = false
        messageLabel.text = "Name: \(name)\nPhone: \(phoneNumber)"
        messageImageView.isHidden = true
        mapView.isHidden = true
    }
    
    private func configureOutgoingMessage() {
        bubbleView.backgroundColor = .systemGreen
        profileImageView.isHidden = true
        
        horizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if !messageImageView.isHidden {
            horizontalStack.addArrangedSubview(UIView())
            horizontalStack.addArrangedSubview(messageImageView)
        } else if !mapView.isHidden {
            horizontalStack.addArrangedSubview(UIView())
            horizontalStack.addArrangedSubview(mapView)
        } else {
            horizontalStack.addArrangedSubview(UIView())
            horizontalStack.addArrangedSubview(bubbleView)
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
        
        if !messageImageView.isHidden {
            horizontalStack.addArrangedSubview(messageImageView)
        } else if !mapView.isHidden {
            horizontalStack.addArrangedSubview(mapView)
        } else {
            horizontalStack.addArrangedSubview(bubbleView)
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
        mapView.isHidden = true
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}


