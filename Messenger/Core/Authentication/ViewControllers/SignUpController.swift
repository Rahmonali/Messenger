//
//  RegisterController.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit

class SignUpController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = AuthHeaderView(title: "Sign Up", subTitle: "Create a new account")
    
    private let fullnameField = CustomTextField(fieldType: .fullname)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signUpButton = CustomButton(title: "Sign Up", hasBackground: true, fontSize: .big)
    private let signInButton = CustomButton(title: "Already have an account? Sign In", fontSize: .med)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDismissKeyboardGesture()
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension SignUpController {
    private func configureUI() {
        
        self.view.backgroundColor = .systemBackground
        
        fullnameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        self.view.addSubview(headerView)
        self.view.addSubview(fullnameField)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signUpButton)
        self.view.addSubview(signInButton)
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.fullnameField.translatesAutoresizingMaskIntoConstraints = false
        self.emailField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordField.translatesAutoresizingMaskIntoConstraints = false
        self.signUpButton.translatesAutoresizingMaskIntoConstraints = false
        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.fullnameField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            self.fullnameField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.fullnameField.heightAnchor.constraint(equalToConstant: heightTextField),
            self.fullnameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.emailField.topAnchor.constraint(equalTo: fullnameField.bottomAnchor, constant: 22),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: heightTextField),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: heightTextField),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.signUpButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signUpButton.heightAnchor.constraint(equalToConstant: heightTextField),
            self.signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 11),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: heightButton),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
}

extension SignUpController {
    private func setupDismissKeyboardGesture() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_: )))
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true) // resign first responder
    }
    
    @objc func didTapSignUp() {
        let registerUserRequest = CreateUserRequest(
            fullname: self.fullnameField.text ?? "",
            email: self.emailField.text ?? "",
            password: self.passwordField.text ?? "", profileImageUrl: nil
        )
        
        if !Regex.isValidEmail(for: registerUserRequest.email) {
            AlertManager.showAlert(on: self, title: "Invalid Email", message: "Please enter a valid email.", buttonText: "Dismiss")
            return
        }
        
        if !Regex.isPasswordValid(for: registerUserRequest.password) {
            AlertManager.showAlert(on: self, title: "Invalid Password", message: "Please enter a valid password.", buttonText: "OK")
            return
        }
        
        Task {
            do {
                try await AuthService.shared.createUser(with: registerUserRequest)
                AlertManager.showAlert(on: self, title: "Your account created", message: "Please log in to your account", buttonText: "OK")
                self.navigationController?.popToRootViewController(animated: true)
            } catch {
                AlertManager.showAlert(on: self, title: "Unknown Registration Error", message: error.localizedDescription, buttonText: "Dismiss")
            }
        }
    }
    
    @objc private func didTapSignIn() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SignUpController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullnameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
}
