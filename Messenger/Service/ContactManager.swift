//
//  ContactManager.swift
//  Messenger
//
//  Created by Rahmonali on 31/01/25.
//

import Contacts
import ContactsUI

protocol ContactManagerDelegate: AnyObject {
    func didSelectContact(name: String, phoneNumber: String)
}

class ContactManager: NSObject, CNContactPickerDelegate {
    
    weak var delegate: ContactManagerDelegate?
    
    private let contactStore = CNContactStore()
    
    func requestContactAccess(completion: @escaping (Bool) -> Void) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func openContactPicker(from viewController: UIViewController) {
        requestContactAccess { [weak self] granted in
            guard let self = self, granted else {
                print("Permission denied")
                return
            }
            
            let picker = CNContactPickerViewController()
            picker.delegate = self
            
            if let sheet = picker.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            
            viewController.present(picker, animated: true)
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = "\(contact.givenName) \(contact.familyName)"
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No phone number"
        
        delegate?.didSelectContact(name: name, phoneNumber: phoneNumber)
    }
}


extension ChatViewController: ContactManagerDelegate {
      func didSelectContact(name: String, phoneNumber: String) {
          Task {
              try await service.sendMessage(type: .contact(name: name, phoneNumber: phoneNumber))
          }
          
          let alert = UIAlertController(
              title: "Contact Selected",
              message: "Name: \(name)\nPhone: \(phoneNumber)",
              preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
}
