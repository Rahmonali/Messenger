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
    let mainViewController = HomeController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        loginViewController.delegate = self
        mainViewController.delegate = self
        
        checkAuthentication()
        
        return true
    }
    
    func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            let loginNavController = UINavigationController(rootViewController: loginViewController)
            loginNavController.modalPresentationStyle = .fullScreen
            setRootViewController(loginNavController)
        } else {
            let mainNavController = UINavigationController(rootViewController: mainViewController)
            mainNavController.modalPresentationStyle = .fullScreen
            setRootViewController(mainNavController)
        }
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
    func didLogout() {
        print("User should logged out")
        checkAuthentication()
    }
}
