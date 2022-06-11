//
//  ManageAccessContentView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

class ManageAccessContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration
    private var model: ManageAcessCellModel?
    weak var delegate: WorkspaceDetailActionsProtocol?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    
    let leftIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(configuration: ManageAccessConfiguration) {
        self.configuration = configuration
        self.model = configuration.model
        super.init(frame: .zero)
        backgroundColor = .yellow
      
        layer.cornerRadius = 22
        addSubview(leftIconImageView)
        addSubview(titleLabel)
        addSubview(rightIconImageView)

        NSLayoutConstraint.activate([
            leftIconImageView.heightAnchor.constraint(equalToConstant: 30),
            leftIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 30),
            leftIconImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -16),
            leftIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(equalTo: rightIconImageView.leadingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 16),
            
            rightIconImageView.heightAnchor.constraint(equalToConstant: 20),
            rightIconImageView.widthAnchor.constraint(equalToConstant: 20),
            rightIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightIconImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),

        ])
        
        if let configModel = configuration.model { applyConfigurationModel(model: configModel) }

        
    }
    
    private func applyConfigurationModel(model: ManageAcessCellModel) {
        titleLabel.text = model.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

