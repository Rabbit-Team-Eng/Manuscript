//
//  FieldButtonContentView.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import UIKit

class FieldButtonContentView: UIView, UIContentView {
    weak var delegate: DatabaseEventProtocol?
    private var model: DatabaseItem?
    var configuration: UIContentConfiguration
    
    let enterIdTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.tag = 999
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "id...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let enterTitleTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.tag = 1000
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "new title...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let myButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#6A67CE")
        button.layer.cornerRadius = 13
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    init(configuration: FieldButtonCellConfiguration) {
        self.configuration = configuration
        self.model = configuration.model
        super.init(frame: .zero)
        
        
        if let configModel = configuration.model { applyConfigurationModel(model: configModel) }
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConfigurationModel(model: DatabaseItem) {
        myButton.setTitle(model.title, for: .normal)

    }
    
    func initViews() {
       
        addSubview(enterIdTextField)
        addSubview(enterTitleTextField)
        addSubview(myButton)
        enterIdTextField.delegate = self
        enterIdTextField.delegate = self
        
        myButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            
            enterIdTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            enterIdTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            enterIdTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            enterIdTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            enterTitleTextField.topAnchor.constraint(equalTo: enterIdTextField.bottomAnchor, constant: 8),
            enterTitleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            enterTitleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            enterTitleTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            myButton.topAnchor.constraint(equalTo: enterTitleTextField.bottomAnchor, constant: 8),
            myButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            myButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            myButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            myButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    @objc func buttonDidTap(_ sender: UIButton) {
        delegate?.eventDidHappen(action: .updateWorkspaceById(id: enterIdTextField.text!, newTitle: enterTitleTextField.text!, entity: model!.entityType))
    }
    

    
}


extension FieldButtonContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @objc func dismissMyKeyboard() {
        self.endEditing(true)
    }
}
