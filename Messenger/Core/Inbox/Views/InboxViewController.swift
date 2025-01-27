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
    private let welcomeLabel = makeLabel(withText: "There are no conversations yet", textStyle: .body, textAlignment: .center, numberOfLines: 2)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfileImageInNavigationBar()
        updateWelcomeLabel()
        tableView.reloadData()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        configureNavigationBar()
        view.addSubview(welcomeLabel)
        view.addSubview(tableView)
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
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateWelcomeLabel() {
        if let user = AuthService.shared.userSession {
            welcomeLabel.text = "There are no conversations yet"
        }
    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.separatorStyle = .none
    }
    
    private func setupProfileImageInNavigationBar() {
        profileImageView.configure(with: UserService.shared.currentUser?.profileImageUrl)
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        profileImageView.addGestureRecognizer(tapGesture)
        let profileBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.leftBarButtonItem = profileBarButtonItem
    }
    
    private func updateEmptyState() {
        let isEmpty = inboxViewModel.filteredMessages.isEmpty
        welcomeLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
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
}

// MARK: - UITableViewDataSource
extension InboxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateEmptyState()
        return inboxViewModel.filteredMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let message = inboxViewModel.filteredMessages[indexPath.row]
        cell.configure(with: message)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = inboxViewModel.filteredMessages[indexPath.row]
        let detailViewController = ChatViewController(recentMessage: message)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == inboxViewModel.filteredMessages.count - 1 {
            print("DEBUG: Paginate here..") // TODO: DEBUG:  I have to work on it in future paginate here..
        }
    }
}
