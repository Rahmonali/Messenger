//
//  SceneDelegate.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit
import FirebaseAuth

/*
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.setupWindow(with: scene)
        self.checkAuthentication()
    }
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    public func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            self.goToController(with: LoginViewController())
        } else {
            self.goToController(with: HomeController())
        }
    }
    
    private func goToController(with viewController: UIViewController) {

        
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.window?.layer.opacity = 0
            } completion: { [weak self] _ in
                
                // Perform the cross-dissolve transition
                UIView.transition(with: self?.window ?? UIView(),
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
                
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .fullScreen
                self?.window?.rootViewController = nav
                
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.window?.layer.opacity = 1
                }
            }
        }
    }
}
*/
