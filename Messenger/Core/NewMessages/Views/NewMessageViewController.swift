//
//  NewMessageViewController.swift
//  Messenger
//
//  Created by Rahmonali on 25/01/25.
//

import UIKit

class NewMessageViewController: UIViewController {
    private let viewModel = NewMessageViewModel()
    private var selectedUser: User?

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "To:"
        return searchBar
    }()

    private let contactsLabel = makeLabel(withText: "CONTACTS", textStyle: .caption1, textColor: .gray, textAlignment: .left)

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewMessageUserTableViewCell.self, forCellReuseIdentifier: NewMessageUserTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        fetchUsers()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "New Message"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))

        view.addSubview(searchBar)
        view.addSubview(contactsLabel)
        view.addSubview(tableView)

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        contactsLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            contactsLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            contactsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contactsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: contactsLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.onUsersUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func fetchUsers() {
        viewModel.fetchUsers()
    }

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewMessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewMessageUserTableViewCell.identifier, for: indexPath) as! NewMessageUserTableViewCell
        let user = viewModel.filteredUsers[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.filteredUsers[indexPath.row]
        dismiss(animated: true) {
            print("Selected user: \(user.fullname)")
        }
    }
}

// MARK: - UISearchBarDelegate
extension NewMessageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
}

#Preview {
    NewMessageViewController()
}
