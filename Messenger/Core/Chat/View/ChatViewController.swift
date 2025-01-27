//
//  ChatViewController.swift
//  Messenger
//
//  Created by Rahmonali on 27/01/25.
//

import UIKit

import UIKit

class ChatViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ChatViewModel
    private let user: User

    private var messagesTableView: UITableView!
    private var messageInputView: MessageInputView!
    private var profileHeaderView: UIView!

    private var messageText: String = ""

    // MARK: - Initializer
    init(user: User, viewModel: ChatViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.observeChatMessages()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.removeChatListener()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Navigation
        navigationItem.title = user.fullname
        navigationController?.navigationBar.prefersLargeTitles = false

        // Profile Header View
        setupProfileHeaderView()

        // Messages Table View
        messagesTableView = UITableView()
        messagesTableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        messagesTableView.dataSource = self
        messagesTableView.separatorStyle = .none
        messagesTableView.backgroundColor = .clear
        view.addSubview(messagesTableView)

        // Message Input View
        messageInputView = MessageInputView()
        messageInputView.delegate = self
        view.addSubview(messageInputView)

        // Auto Layout
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        messagesTableView.translatesAutoresizingMaskIntoConstraints = false
       // messageInputView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Profile Header Constraints
            profileHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileHeaderView.heightAnchor.constraint(equalToConstant: 100),

            // Messages Table View Constraints
            messagesTableView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor),
            messagesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),

            // Message Input View Constraints
//            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupProfileHeaderView() {
        profileHeaderView = UIView()

        let profileImageView = CircularProfileImageView(size: .xLarge)
        profileImageView.configure(with: user.profileImageUrl)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = user.fullname
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textAlignment = .center

        let statusLabel = UILabel()
        statusLabel.text = "Messenger"
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .gray
        statusLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [nameLabel, statusLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        profileHeaderView.addSubview(profileImageView)
        profileHeaderView.addSubview(stackView)
        view.addSubview(profileHeaderView)

        NSLayoutConstraint.activate([
            // Profile Image Constraints
            profileImageView.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 8),

            // Stack View Constraints
            stackView.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: profileHeaderView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.observeChatMessages()
        viewModel.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        let message = viewModel.messages[indexPath.row]
        let nextMessage = viewModel.nextMessage(forIndex: indexPath.row)
        cell.message = message
        cell.nextMessage = nextMessage
        return cell
    }
}

// MARK: - MessageInputViewDelegate
extension ChatViewController: MessageInputViewDelegate {
    func didTapSend(messageText: String) {
        Task {
            do {
                try await viewModel.sendMessage(messageText)
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }

    func didTapSelectImage() {
        // Implement image selection (e.g., show a photo picker)
    }

    func didRemoveSelectedImage() {
        // Remove selected image from view model
        //viewModel.messageImage = nil
    }
}

// MARK: - ChatViewModelDelegate
extension ChatViewController: ChatViewModelDelegate {
    func didUpdateMessages() {
        messagesTableView.reloadData()
        if viewModel.messages.last != nil {
            let lastIndexPath = IndexPath(row: viewModel.messages.count - 1, section: 0)
            messagesTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }

    func didUpdateSelectedImage(_ image: UIImage?) {
        messageInputView.setSelectedImage(image)
    }
}



import Kingfisher

class ChatMessageCell: UITableViewCell {
    // MARK: - Properties
    var message: Message? {
        didSet { configureMessage() }
    }
    var nextMessage: Message?
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        return label
    }()
    
    private let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray4
        return imageView
    }()
    
    private var shouldShowChatPartnerImage: Bool {
        guard let message = message else { return false }
        if nextMessage == nil && !message.isFromCurrentUser { return true }
        guard let next = nextMessage else { return message.isFromCurrentUser }
        return next.isFromCurrentUser
    }
    
    private var isFromCurrentUser: Bool {
        return message?.isFromCurrentUser ?? false
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(messageLabel)
        contentView.addSubview(messageImageView)
        contentView.addSubview(profileImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureMessage() {
        guard let message = message else { return }
        
        // Hide all subviews initially
        messageLabel.isHidden = true
        messageImageView.isHidden = true
        profileImageView.isHidden = true
        
        if shouldShowChatPartnerImage {
            profileImageView.isHidden = false
            profileImageView.frame = CGRect(x: 8, y: 0, width: 32, height: 32)
            if let imageUrl = message.user?.profileImageUrl {
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }
        }
        
        if isFromCurrentUser {
            configureCurrentUserMessage(message)
        } else {
            configurePartnerMessage(message)
        }
    }
    
    private func configureCurrentUserMessage(_ message: Message) {
        switch message.contentType {
        case .text(let text):
            messageLabel.isHidden = false
            messageLabel.text = text
            messageLabel.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            messageLabel.textAlignment = .right
            let textHeight = text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width / 1.5, font: messageLabel.font)
            messageLabel.frame = CGRect(
                x: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 1.5) - 16,
                y: 8,
                width: UIScreen.main.bounds.width / 1.5,
                height: textHeight
            )
        case .image(let imageUrl):
            messageImageView.isHidden = false
            messageImageView.frame = CGRect(
                x: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 1.5) - 16,
                y: 8,
                width: UIScreen.main.bounds.width / 1.5,
                height: 200
            )
            messageImageView.kf.setImage(with: URL(string: imageUrl))
        }
    }
    
    private func configurePartnerMessage(_ message: Message) {
        let leadingOffset: CGFloat = shouldShowChatPartnerImage ? 48 : 8
        
        switch message.contentType {
        case .text(let text):
            messageLabel.isHidden = false
            messageLabel.text = text
            messageLabel.backgroundColor = .systemGray6
            messageLabel.textColor = .black
            messageLabel.textAlignment = .left
            let textHeight = text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width / 1.75, font: messageLabel.font)
            messageLabel.frame = CGRect(
                x: leadingOffset,
                y: 8,
                width: UIScreen.main.bounds.width / 1.75,
                height: textHeight
            )
        case .image(let imageUrl):
            messageImageView.isHidden = false
            messageImageView.frame = CGRect(
                x: leadingOffset,
                y: 8,
                width: UIScreen.main.bounds.width / 1.5,
                height: 200
            )
            messageImageView.kf.setImage(with: URL(string: imageUrl))
        }
    }
}
// MARK: - Helper for Text Size Calculation
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}







class ChatBubbleView: UIView {
    // MARK: - Properties
    var isFromCurrentUser: Bool = false {
        didSet { updateCorners() }
    }
    var shouldRoundAllCorners: Bool = false {
        didSet { updateCorners() }
    }

    private var corners: UIRectCorner {
        if shouldRoundAllCorners {
            return .allCorners
        } else {
            return [
                .topLeft,
                .topRight,
                isFromCurrentUser ? .bottomLeft : .bottomRight
            ]
        }
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.masksToBounds = true
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }

    private func updateCorners() {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 16, height: 16)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


protocol ChatViewModelDelegate: AnyObject {
    func didUpdateMessages()
    func didUpdateSelectedImage(_ image: UIImage?)
}

class ChatViewModel {
    // MARK: - Properties
    weak var delegate: ChatViewModelDelegate?

    private(set) var messages: [Message] = [] {
        didSet { delegate?.didUpdateMessages() }
    }
    private(set) var messageImage: UIImage? {
        didSet { delegate?.didUpdateSelectedImage(messageImage) }
    }

    private let service: ChatService
    private var uiImage: UIImage?

    // MARK: - Initializer
    init(user: User) {
        self.service = ChatService(chatPartner: user)
    }

    // MARK: - Public Methods
    func observeChatMessages() {
        service.observeMessages { [weak self] messages in
            guard let self = self else { return }
            self.messages.append(contentsOf: messages)
        }
    }

    func sendMessage(_ messageText: String) async throws {
        if let image = uiImage {
            try await service.sendMessage(type: .image(image))
            clearImage()
        } else {
            try await service.sendMessage(type: .text(messageText))
        }
    }

    func updateMessageStatusIfNecessary() async throws {
        guard let lastMessage = messages.last else { return }
        try await service.updateMessageStatusIfNecessary(lastMessage)
    }

    func nextMessage(forIndex index: Int) -> Message? {
        return index < messages.count - 1 ? messages[index + 1] : nil
    }

    func removeChatListener() {
        service.removeListener()
    }

    // MARK: - Private Methods
    private func clearImage() {
        uiImage = nil
        messageImage = nil
    }
}






protocol MessageInputViewDelegate: AnyObject {
    func didTapSend(messageText: String)
    func didTapSelectImage()
    func didRemoveSelectedImage()
}

class MessageInputView: UIView {
    // MARK: - Properties
    weak var delegate: MessageInputViewDelegate?

    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Message.."
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 20
        textField.layer.masksToBounds = true
        textField.setLeftPaddingPoints(12)
        textField.setRightPaddingPoints(12)
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    private let imagePreview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let removeImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.isHidden = true
        return button
    }()

    private let photoPickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .gray
        return button
    }()

    private var messageImage: UIImage? {
        didSet {
            updateImagePreview()
        }
    }

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        addSubview(messageTextField)
        addSubview(sendButton)
        addSubview(imagePreview)
        addSubview(removeImageButton)
        addSubview(photoPickerButton)
        
        sendButton.addTarget(self, action: #selector(handleSendButtonTapped), for: .touchUpInside)
        removeImageButton.addTarget(self, action: #selector(handleRemoveImageTapped), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(handlePhotoPickerTapped), for: .touchUpInside)



        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        removeImageButton.translatesAutoresizingMaskIntoConstraints = false
        photoPickerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Image Preview Constraints
            imagePreview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imagePreview.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imagePreview.widthAnchor.constraint(equalToConstant: 80),
            imagePreview.heightAnchor.constraint(equalToConstant: 140),

            removeImageButton.topAnchor.constraint(equalTo: imagePreview.topAnchor, constant: -4),
            removeImageButton.trailingAnchor.constraint(equalTo: imagePreview.trailingAnchor, constant: 4),
            removeImageButton.widthAnchor.constraint(equalToConstant: 24),
            removeImageButton.heightAnchor.constraint(equalToConstant: 24),

            // TextField Constraints
            messageTextField.leadingAnchor.constraint(equalTo: imagePreview.isHidden ? leadingAnchor : imagePreview.trailingAnchor, constant: 8),
            messageTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            // Send Button Constraints
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Photo Picker Button Constraints
            photoPickerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            photoPickerButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            photoPickerButton.widthAnchor.constraint(equalToConstant: 40),
            photoPickerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // MARK: - Actions
    @objc private func handleSendButtonTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        delegate?.didTapSend(messageText: text)
        messageTextField.text = ""
    }

    @objc private func handlePhotoPickerTapped() {
        delegate?.didTapSelectImage()
    }

    @objc private func handleRemoveImageTapped() {
        messageImage = nil
        delegate?.didRemoveSelectedImage()
    }

    // MARK: - Helper Methods
    private func updateImagePreview() {
        if let image = messageImage {
            imagePreview.image = image
            imagePreview.isHidden = false
            removeImageButton.isHidden = false
        } else {
            imagePreview.isHidden = true
            removeImageButton.isHidden = true
        }
    }

    func setSelectedImage(_ image: UIImage?) {
        self.messageImage = image
    }
}

// MARK: - UITextField Padding Helper
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

