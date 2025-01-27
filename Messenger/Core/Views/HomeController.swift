//
//  HomeController.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeController: UIViewController {
    
    let profileImageView = CircularProfileImageView(size: .xSmall)
    private let profileViewModel = ProfileViewModel()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = ""
        label.numberOfLines = 2
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = AuthService.shared.userSession {
            self.label.text = "\(String(describing: user.email))"
        }
        
        setupProfileImageInNavigationBar()
    }
    
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapNewMessage)
        )
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
}

// MARK: Actions
extension HomeController {
    @objc private func didTapNewMessage() {
        let newMessageViewController = NewMessageViewController()
        let navController = UINavigationController(rootViewController: newMessageViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func didTapProfile() {
        if let user = UserService.shared.currentUser {
            let profileViewController = ProfileViewController(user: user, profileViewModel: profileViewModel)
            let navController = UINavigationController(rootViewController: profileViewController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
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
