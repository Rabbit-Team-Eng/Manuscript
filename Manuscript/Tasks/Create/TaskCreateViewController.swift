//
//  TaskCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

class TaskCreateViewController: UIViewController {
    
    weak var coordinator: TabBarCoordinator? = nil
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .title2, weight: .bold)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "Create new Task"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "DETAILES"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let enterNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.placeholder = "Title"
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let enterDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.placeholder = "Description (optional)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createNewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Create New Task"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mediumDarkGray
        
        closeButton.addTarget(self, action: #selector(closeScreen(_:)), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(titleTexLabel)
        view.addSubview(nameTextLabel)
        view.addSubview(enterNameTextField)
        view.addSubview(enterDescriptionTextField)
        view.addSubview(createNewTaskButton)

    }
    
    @objc private func closeScreen(_ sender: UIButton) {
        coordinator?.dismissTaskCreationSheet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            titleTexLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -32),
            titleTexLabel.heightAnchor.constraint(equalToConstant: 24),
            
            closeButton.centerYAnchor.constraint(equalTo: titleTexLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),

            nameTextLabel.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 24),
            nameTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            nameTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nameTextLabel.heightAnchor.constraint(equalToConstant: 15),

            enterNameTextField.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 8),
            enterNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            enterNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            enterNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            enterDescriptionTextField.topAnchor.constraint(equalTo: enterNameTextField.bottomAnchor, constant: 16),
            enterDescriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            enterDescriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            enterDescriptionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            createNewTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            createNewTaskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createNewTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createNewTaskButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }


}
