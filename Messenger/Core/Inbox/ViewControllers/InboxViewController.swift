//
//  InboxViewController.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InboxViewController: UIViewController {
    
    private let profileViewModel = ProfileViewModel()
    private let inboxViewModel = InboxViewModel()
    
    private let profileImageView = CircularProfileImageView(size: .xSmall)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
        setEmptyStateIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfileImageInNavigationBar()
        fetchCurrentUserAndReloadTable()
        tableView.reloadData()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        configureNavigationBar()
        setupConstraints()
    }
    
    private func configureNavigationBar() {
        title = "Chats"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapNewMessage)
        )
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchCurrentUserAndReloadTable() {
        if let user = UserService.shared.currentUser {
            self.profileImageView.configure(with: user.profileImageUrl)
        }

        UserService.shared.currentUserDidChange = { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileImageView.configure(with: user?.profileImageUrl)
                self.tableView.reloadData()
                self.setEmptyStateIfNeeded()
            }
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupProfileImageInNavigationBar() {
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        profileImageView.addGestureRecognizer(tapGesture)
        let profileBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.leftBarButtonItem = profileBarButtonItem
    }
    
    private func setEmptyStateIfNeeded() {
        if inboxViewModel.recentMessages.isEmpty{
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
    
    // MARK: - Actions
    @objc private func didTapNewMessage() {
        let newMessageVC = NewMessageViewController()
        let navController = UINavigationController(rootViewController: newMessageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func didTapProfile() {
        guard let user = UserService.shared.currentUser else { return }
        let profileVC = ProfileViewController(user: user, profileViewModel: profileViewModel)
        let navController = UINavigationController(rootViewController: profileVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func handleRefresh() {
        inboxViewModel.setupSubscribers()
        setEmptyStateIfNeeded()
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension InboxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxViewModel.recentMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let message = inboxViewModel.recentMessages[indexPath.row]
        cell.configure(with: message)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = inboxViewModel.recentMessages[indexPath.row]
        guard let user = message.user else { return }
        let chatViewController = ChatViewController(user: user)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                self?.deleteMessage(at: indexPath)
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        private func deleteMessage(at indexPath: IndexPath) {
            let message = inboxViewModel.recentMessages[indexPath.row]
            Task {
                do {
                    try await inboxViewModel.deleteMessage(message)
                    await MainActor.run {
                        self.tableView.performBatchUpdates {
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.setEmptyStateIfNeeded()
                        }
                    }
                } catch {
                    print("DEBUG: Failed to delete message - \(error.localizedDescription)")
                }
            }
        }
}
