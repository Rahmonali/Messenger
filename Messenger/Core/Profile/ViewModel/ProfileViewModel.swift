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
        guard let imageUrl = await uploadProfileImage(image) else { return }
        do {
            try await UserService.shared.updateUserProfileImageUrl(imageUrl)
            await loadUserProfileImage(from: imageUrl)
        } catch {
            print("Failed to update user profile image URL: \(error.localizedDescription)")
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
