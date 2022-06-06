//
//  CreateNewBoardViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/4/22.
//

import UIKit

class CreateNewBoardViewController: UIViewController {
    
    weak var parentCoordinator: TabBarCoordinator? = nil
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .title2, weight: .bold)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "Create new board"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "NAME"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let enterNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let iconTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "ICON"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addSubview(titleTexLabel)
        view.addSubview(nameTextLabel)
        view.addSubview(enterNameTextField)
        view.addSubview(iconTextLabel)

        view.backgroundColor = Palette.mediumDarkGray
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            titleTexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            titleTexLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameTextLabel.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 24),
            nameTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            nameTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nameTextLabel.heightAnchor.constraint(equalToConstant: 15),

            enterNameTextField.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 8),
            enterNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            enterNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            enterNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            iconTextLabel.topAnchor.constraint(equalTo: enterNameTextField.bottomAnchor, constant: 16),
            iconTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            iconTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            iconTextLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

}
