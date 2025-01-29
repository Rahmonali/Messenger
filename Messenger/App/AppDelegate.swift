//
//  AppDelegate.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let loginViewController = LoginViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupWindow()
        registerForNotifications()
        checkAuthentication()
        loginViewController.delegate = self
        
        return true
    }
    
    private func setupWindow() {
         window = UIWindow(frame: UIScreen.main.bounds)
         window?.backgroundColor = .systemBackground
     }
         
    func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            let loginNavController = UINavigationController(rootViewController: loginViewController)
            loginNavController.modalPresentationStyle = .fullScreen
            setRootViewController(loginNavController)
        } else {
            let inboxViewController = InboxViewController()
            let mainNavController = UINavigationController(rootViewController: inboxViewController)
            mainNavController.modalPresentationStyle = .fullScreen
            setRootViewController(mainNavController)
        }
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout), name: .logout, object: nil)
    }
}

extension AppDelegate {
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated, let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
}

extension AppDelegate: LoginViewControllerDelegate {
    func didLogin() {
        checkAuthentication()
    }
}

extension AppDelegate: LogoutDelegate {
    @objc func didLogout() {
        checkAuthentication()
    }
}
