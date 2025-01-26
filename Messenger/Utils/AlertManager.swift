//
//  AlertManager.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit

class AlertManager {
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String?, buttonText: String = "Dismiss") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
    
    public static func showAlert(on vc: UIViewController, title: String, message: String?, buttonText: String) {
        self.showBasicAlert(on: vc, title: title, message: message, buttonText: buttonText)
    }
}
