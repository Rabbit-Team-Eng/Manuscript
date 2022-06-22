//
//  InputCellContentView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/20/22.
//

import UIKit

class InputCellContentView: UIView, UIContentView, UITextFieldDelegate {
    
    weak var delegate: KaleidoscopeProtocol?
    private var model: InputCardCellModel?
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
    
    init(configuration: InputCellContentConfiguration) {
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
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 0),
            descriptionTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 60),
            descriptionTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

        ])
        
        if let configModel = configuration.model { applyConfigurationModel(model: configModel) }

        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == titleTextField {

        }
        
        if textField == descriptionTextField {

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConfigurationModel(model: InputCardCellModel) {
        guard let config = configuration as? InputCellContentConfiguration, let model = config.model else { return }
        self.model = model
        
        titleTextField.text = model.firstText
        descriptionTextField.text = model.secondText
    }


}
