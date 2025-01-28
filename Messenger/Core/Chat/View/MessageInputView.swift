//
//  MessageInputView.swift
//  Messenger
//
//  Created by Rahmonali on 28/01/25.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func didSendMessage(_ text: String)
}

class MessageInputView: UIView {
    weak var delegate: MessageInputViewDelegate?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Message..."
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
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
        
        backgroundColor = .systemGroupedBackground
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    @objc private func handleSend() {
        guard let text = textField.text, !text.isEmpty else { return }
        delegate?.didSendMessage(text)
        textField.text = nil
    }
}
