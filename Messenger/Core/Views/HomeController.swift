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
    
    private let profileImageView: CircularProfileImageView = CircularProfileImageView(size: .small)
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = ""
        label.numberOfLines = 2
        return label
    }()
    
    weak var delegate: LogoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        if let user = AuthService.shared.userSession {
            self.label.text = "\(String(describing: user.email))"
        }
    }
    
    private func setupUI() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person"),
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        
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
    
    @objc private func didTapLogout(sender: UIButton) {
        Task {
            do {
                try AuthService.shared.signOut()
                self.delegate?.didLogout()
                self.label.text = ""
            } catch {
                AlertManager.showLogoutError(on: self, with: error)
            }
        }
    }
    
    
    @objc private func didTapNewMessage() {
        let newMessageViewController = NewMessageViewController()
        let navController = UINavigationController(rootViewController: newMessageViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func didTapProfile() {
     
        if let user = UserService.shared.currentUser {
            let profileViewController = ProfileViewController(user: user)
            let navController = UINavigationController(rootViewController: profileViewController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
}
