//
//  IconView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import UIKit

class IconSelectorView: UIView, UIContentView {
    
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
        addSubview(iconImageView)
        applyConfiguration(configuration: configuration)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        ])
    }
    
    private func applyConfiguration(configuration: UIContentConfiguration) {
        
        guard let config = configuration as? IconSelectorContentConfiguration, let model = config.model else { return }
        iconImageView.image = UIImage(systemName: model.iconResource)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
