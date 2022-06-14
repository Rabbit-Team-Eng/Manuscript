//
//  TaskGeneralInfoContentView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

class TaskGeneralInfoContentView: UIView, UIContentView, UITextFieldDelegate {
    
    weak var delegate: TaskDetailActionProtocol?
    private var model: TaskGeneralInfoCellModel?
    var configuration: UIContentConfiguration
    
    let titleTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.setLeftPaddingPoints(10)
        textField.layer.cornerRadius = 12
        textField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let descriptionTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.setLeftPaddingPoints(10)
        textField.layer.cornerRadius = 12
        textField.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    init(configuration: TaskGeneralInfoConfiguration) {
        self.configuration = configuration
        self.model = configuration.model
        super.init(frame: .zero)
        
        addSubview(titleTextField)
        addSubview(descriptionTextField)
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        
        backgroundColor = Palette.lightBlack
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleTextField.heightAnchor.constraint(equalToConstant: 60),
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 0.5),
            descriptionTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        if let configModel = configuration.model { applyConfigurationModel(model: configModel) }

        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == titleTextField {
            delegate?.actionDidHappen(action: .titleDidUpdated(text: textField.text ?? "null"))
        }
        
        if textField == descriptionTextField {
            delegate?.actionDidHappen(action: .descriptionDidUpdated(text: textField.text ?? "null"))

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConfigurationModel(model: TaskGeneralInfoCellModel) {
        titleTextField.text = model.title
        descriptionTextField.text = model.description
        titleTextField.isUserInteractionEnabled = model.isEditable
        descriptionTextField.isUserInteractionEnabled = model.isEditable
        
        if model.needPlaceholders {
            titleTextField.placeholder = "Enter title"
            descriptionTextField.placeholder = "Enter desciption"
        }
    }


}
