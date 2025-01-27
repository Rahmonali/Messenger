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
    
    let profileImageView = CircularProfileImageView(size: .xSmall)
    private let profileViewModel = ProfileViewModel()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWelcomeLabel()
        setupProfileImageInNavigationBar()
    }
    
    private func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .systemBackground
        view.addSubview(welcomeLabel)
        setupConstraints()
    }
    
    private func configureNavigationBar() {
        // Configure right bar button for new message
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapNewMessage)
        )
    }
    
    private func setupConstraints() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func updateWelcomeLabel() {
        if let user = AuthService.shared.userSession {
            welcomeLabel.text = "Welcome, \(user.email ?? "User")"
        } else {
            welcomeLabel.text = "Welcome, Guest"
        }
    }
}

// MARK: Actions
extension InboxViewController {
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
    
    
    private func setupProfileImageInNavigationBar() {
        profileImageView.configure(with: UserService.shared.currentUser?.profileImageUrl)
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        profileImageView.addGestureRecognizer(tapGesture)
        let profileBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.leftBarButtonItem = profileBarButtonItem
    }
}
