//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Rahmonali on 26/01/25.
//

import UIKit
import FirebaseStorage

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
