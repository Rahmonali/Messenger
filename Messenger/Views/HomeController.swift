//
//  HomeController.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit

class HomeController: UIViewController {
    
    // MARK: - UI Components
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
        Task {
            do {
                let user = try await AuthService.shared.fetchUser()
                self.label.text = "\(user.username)\n\(user.email)"
            } catch {
                AlertManager.showFetchingUserError(on: self, with: error)
            }
        }
    }
        
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        
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
}
