//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Rahmonali on 26/01/25.
//

import UIKit
import PhotosUI

class ProfileViewController: UIViewController {
    
    private let user: User
    let profileViewModel: ProfileViewModel
    
    private lazy var profileImageView: CircularProfileImageView = {
        let imageView = CircularProfileImageView(size: .xLarge)
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        button.isEnabled = false
        return button
    }()
    
    private let logoutButton = CustomButton(title: "Logout", fontSize: .small)
    
    private let fullnameField = CustomTextField(fieldType: .fullname)
    
    init(user: User, profileViewModel: ProfileViewModel) {
        self.user = user
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: LogoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileViewModel.delegate = self
        configureUI()
        
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        fetchUserProfileImage()
        fullnameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = saveButton
        
        let email = makeLabel(withText: user.email, textStyle: .caption1, textColor: .darkGray, textAlignment: .center, numberOfLines: 0)
        fullnameField.text = user.fullname
        
        let stackView = UIStackView(arrangedSubviews: [profileImageView, email, fullnameField])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitleColor(.red, for: .normal)
        
        view.addSubview(stackView)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: ProfileImageSize.xLarge.dimension),
            profileImageView.heightAnchor.constraint(equalToConstant: ProfileImageSize.xLarge.dimension),
            
            fullnameField.heightAnchor.constraint(equalToConstant: heightTextField),
            fullnameField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: fullnameField.trailingAnchor, multiplier: 1),
            
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8), // Adjust constant as needed
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func didTapLogout(sender: UIButton) {
        Task {
            do {
                try AuthService.shared.signOut()
                self.delegate?.didLogout()
                NotificationCenter.default.post(name: .logout, object: nil)
            } catch {
                AlertManager.showAlert(on: self, title: "Log Out Error", message: error.localizedDescription, buttonText: "Dismiss")
            }
        }
    }
    
    
}

// MARK: Actions
extension ProfileViewController {
    @objc private func didTapChangeProfilePicture() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSave() {
        guard let updatedFullname = fullnameField.text, !updatedFullname.isEmpty else { return }
        Task {
            do {
                try await UserService.shared.updateUserFullname(updatedFullname)
                view.endEditing(true) // Hide the keyboard
                AlertManager.showAlert(on: self, title: "Your fullname has been updated successfully.", message: nil, buttonText: "OK")
                saveButton.isEnabled = false
            } catch {
                print("Error updating fullname: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        saveButton.isEnabled = fullnameField.text?.isEmpty == false
    }
}

// MARK: ProfileViewModelDelegate
extension ProfileViewController: ProfileViewModelDelegate {
    private func fetchUserProfileImage() {
        Task { await profileViewModel.loadUserProfileImage(from: user.profileImageUrl) }
    }
    
    func didUpdateProfileImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
            
        }
    }
}

// MARK: PHPickerViewControllerDelegate
extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let item = results.first else { return }
        item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            if let image = object as? UIImage {
                Task {
                    await self?.profileViewModel.updateProfileImage(image)
                }
            }
        }
    }
}

#Preview {
    ProfileViewController(user: User(
        userId: "234353",
        fullname: "Rahmonali",
        email: "rahmonali1995@gmail.com",
        profileImageUrl: nil),
                          profileViewModel: ProfileViewModel()
    )
}

