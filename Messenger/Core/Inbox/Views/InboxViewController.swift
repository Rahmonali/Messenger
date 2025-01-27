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
        fetchCurrentUserAndReloadTable()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .systemBackground
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
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchCurrentUserAndReloadTable() {
        UserService.shared.currentUserDidChange = { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileImageView.configure(with: user?.profileImageUrl)
                self.tableView.reloadData()
                
                self.updateWelcomeLabel()
            }
        }
    }
    
    private func updateWelcomeLabel() {
        let hasConversations = !inboxViewModel.filteredMessages.isEmpty
       // welcomeLabel.isHidden = hasConversations
        //tableView.isHidden = !hasConversations
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
    }
    
    private func setupProfileImageInNavigationBar() {
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        profileImageView.addGestureRecognizer(tapGesture)
        let profileBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.leftBarButtonItem = profileBarButtonItem
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
        guard let user = message.user else { return }
        let viewModel = ChatViewModel(user: user)
        let detailViewController = ChatViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == inboxViewModel.filteredMessages.count - 1 {
            print("DEBUG: Paginate shoud be here here..")
        }
    }
}
