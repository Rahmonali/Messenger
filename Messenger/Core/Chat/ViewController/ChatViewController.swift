//
//  ChatViewController.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//


import UIKit
import PhotosUI
import Kingfisher

class ChatViewController: UIViewController {
    private let user: User
    private var messages: [Message] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var messageInputView: MessageInputView = {
        let inputView = MessageInputView()
        inputView.delegate = self
        return inputView
    }()
    
    private let service: ChatService
    
    init(user: User) {
        self.user = user
        self.service = ChatService(chatPartner: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeChatMessages()
        setEmptyStateIfNeeded()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = user.fullname
        
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func observeChatMessages() {
        service.observeMessages { [weak self] newMessages in
            guard let self = self else { return }
            let uniqueMessages = newMessages.filter { !self.messages.contains($0) }
            self.messages.append(contentsOf: uniqueMessages)
            DispatchQueue.main.async {
                self.setEmptyStateIfNeeded()
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func sendMessage(_ text: String) {
        Task {
            try await service.sendMessage(type: .text(text))
        }
    }
    
    private func setEmptyStateIfNeeded() {
        if messages.isEmpty {
            let emptyLabel = makeLabel(withText: "There is no conversation yet", textStyle: .headline, textColor: .gray, textAlignment: .center, numberOfLines: 2)
            let containerView = UIView()
            containerView.addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
            tableView.backgroundView = containerView
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message, user: user)
        return cell
    }
}

extension ChatViewController: MessageInputViewDelegate {
    func didSendMessage(_ text: String) {
        sendMessage(text)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
}

