//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Rahmonali on 26/01/25.
//

import UIKit
import PhotosUI


import FirebaseStorage

class ProfileViewController: UIViewController {

    private let user: User
    private let viewModel = ProfileViewModel()
    
    private lazy var profileImageView: CircularProfileImageView = {
        let imageView = CircularProfileImageView(size: .xLarge)
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(didTapChangeProfilePicture), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        viewModel.loadUserProfileImage(from: user.profileImageUrl)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))

        
        fullnameLabel.text = user.fullname
        
        let stack = UIStackView(arrangedSubviews: [profileImageView, fullnameLabel, editProfileButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: ProfileImageSize.xLarge.dimension),
            profileImageView.heightAnchor.constraint(equalToConstant: ProfileImageSize.xLarge.dimension),
            
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onProfileImageUpdate = { [weak self] image in
            self?.profileImageView.image = image
        }
    }
    
    // MARK: - Actions
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
}

// MARK: - PHPickerViewControllerDelegate
extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let item = results.first else { return }
        item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            if let image = object as? UIImage {
                Task {
                    await self?.viewModel.updateProfileImage(image)
                }
            }
        }
    }
}









class ProfileViewModel {
    var onProfileImageUpdate: ((UIImage?) -> Void)?
    
    func loadUserProfileImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            onProfileImageUpdate?(UIImage(systemName: "person.circle.fill"))
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.onProfileImageUpdate?(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.onProfileImageUpdate?(UIImage(systemName: "person.circle.fill"))
                }
            }
        }
    }
    
    func updateProfileImage(_ image: UIImage) async {
        guard let imageUrl = await uploadProfileImage(image) else { return }
        // Update the user's profile image URL in the database
        do {
            try await UserService.shared.updateUserProfileImageUrl(imageUrl)
            loadUserProfileImage(from: imageUrl)
        } catch {
            print("Failed to update user profile image URL.")
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        
        do {
            _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("Failed to upload profile image: \(error.localizedDescription)")
            return nil
        }
    }
}



