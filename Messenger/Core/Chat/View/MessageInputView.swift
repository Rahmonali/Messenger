//
//  MessageInputView.swift
//  Messenger
//
//  Created by Rahmonali on 28/01/25.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func didSendMessage(_ text: String)
    func didTapImageButton() // New delegate method for image selection
}

class MessageInputView: UIView {
    weak var delegate: MessageInputViewDelegate?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Message..."
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .default
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    private let imageButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "photo") // System icon for images
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textField)
        addSubview(sendButton)
        addSubview(imageButton)
        
        backgroundColor = .systemGroupedBackground
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            imageButton.widthAnchor.constraint(equalToConstant: 30),
            
            textField.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 8),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 8),
            
            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(handleImageSelection), for: .touchUpInside)
    }
    
    func sendMessage() {
        guard let text = textField.text, !text.isEmpty else { return }
        delegate?.didSendMessage(text)
        textField.text = nil
    }
    
    @objc private func handleSend() {
        sendMessage()
    }
    
    @objc private func handleImageSelection() {
        delegate?.didTapImageButton()
    }
}

extension MessageInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
