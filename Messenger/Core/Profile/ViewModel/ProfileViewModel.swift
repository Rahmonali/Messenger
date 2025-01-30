//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Rahmonali on 26/01/25.
//

import UIKit
import FirebaseStorage

protocol ProfileViewModelDelegate: AnyObject {
    func didUpdateProfileImage(_ image: UIImage?)
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    
    func loadUserProfileImage(from urlString: String?) async {
        let placeholderImage = UIImage(systemName: "person.circle.fill")
        guard let urlString = urlString, let url = URL(string: urlString) else {
            delegate?.didUpdateProfileImage(placeholderImage)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data) ?? placeholderImage
            delegate?.didUpdateProfileImage(image)
        } catch {
            delegate?.didUpdateProfileImage(placeholderImage)
        }
    }
    
    func updateProfileImage(_ image: UIImage) async {
        guard let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .profile) else { return }
        await loadUserProfileImage(from: imageUrl)
        do {
            try await UserService.shared.updateUserProfileImageUrl(imageUrl)
        } catch {
            print("Failed to update user profile image URL: \(error.localizedDescription)")
        }
    }
}
