//
//  SingleButtonContentView.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import UIKit

class SingleButtonContentView: UIView, UIContentView, UITextFieldDelegate {
    weak var delegate: DatabaseEventProtocol?
    private var model: DatabaseItem?
    var configuration: UIContentConfiguration
    
    let myButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#6A67CE")
        button.layer.cornerRadius = 13
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    init(configuration: SingleButtonCellConfiguration) {
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
        addSubview(myButton)
        myButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            myButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            myButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            myButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            myButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            myButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    @objc func buttonDidTap(_ sender: UIButton) {
        delegate?.eventDidHappen(action: .createNewWorkspace)
    }
    

    
}

