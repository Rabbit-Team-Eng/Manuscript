//
//  TaskBoardSelectorView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

class TaskBoardSelectorView: UIView, UIContentView {
        
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .headline, weight: .regular)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var configuration: UIContentConfiguration {
        didSet {
            applyConfiguration(configuration: configuration)
        }
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addSubview(titleTexLabel)
        addSubview(iconImageView)
        applyConfiguration(configuration: configuration)
        
        NSLayoutConstraint.activate([
            titleTexLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleTexLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleTexLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: -8),
            titleTexLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    private func applyConfiguration(configuration: UIContentConfiguration) {
        
        guard let config = configuration as? TaskBoardSelectorContentConfiguration, let model = config.model else { return }
        titleTexLabel.text = model.title
        iconImageView.image = UIImage(systemName: model.iconResource)

    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
