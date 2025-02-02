//
//  ChatViewController.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//


import UIKit
import PhotosUI
import Kingfisher
import CoreLocation

class ChatViewController: UIViewController {
    private let user: User
    private var messages: [Message] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var messageInputView: MessageInputView = {
        let inputView = MessageInputView()
        inputView.delegate = self
        contactManager.delegate = self
        return inputView
    }()
    
    private var messageInputViewBottomConstraint: NSLayoutConstraint!
    private let locationManager = CLLocationManager()
    private let contactManager = ContactManager()

    let service: ChatService
    
    init(user: User) {
        self.user = user
        self.service = ChatService(chatPartner: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeChatMessages()
        setEmptyStateIfNeeded()
        setupKeyboardHiding()
        setupDismissKeyboardGesture()
        
        Task { try await updateMessageStatusIfNecessary() }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = user.fullname
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(selectContact)
        )
        
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputViewBottomConstraint,
            messageInputView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    @objc private func selectContact() {
          contactManager.openContactPicker(from: self)
      }
    
    
    private func observeChatMessages() {
        service.observeMessages { [weak self] newMessages in
            guard let self = self else { return }
            let uniqueMessages = newMessages.filter { !self.messages.contains($0) }
            self.messages.append(contentsOf: uniqueMessages)
            DispatchQueue.main.async {
                self.setEmptyStateIfNeeded()
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func updateMessageStatusIfNecessary() async throws {
        guard let lastMessage = messages.last else { return }
        try await service.updateMessageStatusIfNecessary(lastMessage)
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func sendMessage(_ text: String) {
        Task {
            try await service.sendMessage(type: .text(text))
        }
    }
    
    private func sendImageMessage(_ image: UIImage) {
        Task {
            try await service.sendMessage(type: .image(image))
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupDismissKeyboardGesture() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_: )))
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func setEmptyStateIfNeeded() {
        if messages.isEmpty {
            let emptyLabel = makeLabel(withText: "There is no conversation yet", textStyle: .headline, textColor: .gray, textAlignment: .center, numberOfLines: 2)
            let containerView = UIView()
            containerView.addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
            tableView.backgroundView = containerView
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message, user: user)
        return cell
    }
}

extension ChatViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        messageInputViewBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        messageInputViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if let selectedImage = info[.originalImage] as? UIImage {
                self?.sendImageMessage(selectedImage)
            }
        }
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let selectedImage = image as? UIImage, error == nil else { return }
            DispatchQueue.main.async {
                self.sendImageMessage(selectedImage)
            }
        }
    }
}

extension ChatViewController: MessageInputViewDelegate {
    func didSendMessage(_ text: String) {
        sendMessage(text)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func didTapLocationButton() {
        requestLocationPermission()
    }
    
    func didTapImageButton() {
        let alert = UIAlertController(title: "Select Image", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default, handler: { _ in
            self.presentImagePicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: { _ in
            self.presentCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension ChatViewController: CLLocationManagerDelegate {
    
    private func requestLocationPermission() {
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            fetchCurrentLocation()
        case .denied, .restricted:
            presentLocationPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func presentLocationPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Location Access Denied",
                message: "Enable location access in Settings to share your location.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            self.present(alert, animated: true)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                fetchCurrentLocation()
            } else {
                print("Location services are disabled.")
            }
        case .denied, .restricted:
            presentLocationPermissionAlert()
        default:
            break
        }
    }
    
    private func fetchCurrentLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocationMessage(location)        
        locationManager.stopUpdatingLocation()
    }
    
    private func sendLocationMessage(_ location: CLLocation) {
        Task(priority: .background) {
            do {
                try await service.sendMessage(type: .location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                
                DispatchQueue.main.async {
                    self.reloadChatData()
                }
            } catch {
                print("Failed to send location message: \(error.localizedDescription)")
            }
        }
    }
    
    private func reloadChatData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
