//
//  TaskCellContentView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class TaskCellContentView: UIView, UIContentView {
    
    weak var delegate: TaskCellProtocol?
    var model: TaskCellModel?

    private let titleTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .headline, weight: .heavy)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextLabel: UILabel = {
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
        addSubview(titleTextLabel)
        addSubview(iconImageView)
        addSubview(descriptionTextLabel)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemDidSelected(_:))))
        
        applyConfiguration(configuration: configuration)
        
                
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleTextLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleTextLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleTextLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            
            descriptionTextLabel.topAnchor.constraint(equalTo: titleTextLabel.bottomAnchor, constant: 8),
            descriptionTextLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            descriptionTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        
    }
    
    @objc private func itemDidSelected(_ sender: UIView) {
        if let task = model, let delegate = delegate {
            delegate.taskDidSelected(task: task)
        }
    }
    
    
    private func applyConfiguration(configuration: UIContentConfiguration) {
        
        guard let config = configuration as? TaskCellContentConfiguration, let model = config.model else { return }
        self.model = model
        titleTextLabel.text = model.title
        descriptionTextLabel.text = model.description
        
        var highlightColor: UIColor = .red.withAlphaComponent(0.3)
        
        if model.priority == .high {
            iconImageView.image = UIImage(systemName: "chevron.up.square.fill")
            iconImageView.tintColor = Palette.red

        } else if model.priority == .medium {
            iconImageView.image = UIImage(systemName: "equal.square.fill")
            iconImageView.tintColor = Palette.blue
            highlightColor = .blue.withAlphaComponent(0.3)
            
        } else if model.priority == .low {
            iconImageView.image = UIImage(systemName: "chevron.down.square.fill")
            iconImageView.tintColor = Palette.green
            highlightColor = .green.withAlphaComponent(0.3)
        }


    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

