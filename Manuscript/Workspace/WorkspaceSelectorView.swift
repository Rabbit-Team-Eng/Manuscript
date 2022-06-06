//
//  WorkspaceSelectorView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit

class WorkspaceSelectorView: UIView, UIContentView {
    
    weak var delegate: WorkspaceSelectorProtocol?
    
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
    
    private let editWorkspaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "slider.horizontal.3")
        button.setTitleColor(Palette.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        addSubview(editWorkspaceButton)
        editWorkspaceButton.addTarget(self, action: #selector(editWorkspaceButtonDidTap(_:)), for: .touchUpInside)
        applyConfiguration(configuration: configuration)
        
    }
    
    @objc private func editWorkspaceButtonDidTap(_ sender: UIButton) {
        guard let delegate = delegate, let config = configuration as? WorkspaceSelectorContentConfiguration, let model = config.model else { return }
        delegate.workspaceDidSelected(model: model)
    }
    
    private func applyConfiguration(configuration: UIContentConfiguration) {
        
        guard let config = configuration as? WorkspaceSelectorContentConfiguration, let model = config.model else { return }
        titleTexLabel.text = model.title
        
        if model.isEditable {
            editWorkspaceButton.isHidden = false
        } else {
            editWorkspaceButton.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            titleTexLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleTexLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleTexLabel.trailingAnchor.constraint(equalTo: editWorkspaceButton.leadingAnchor, constant: -8),
            titleTexLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            editWorkspaceButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            editWorkspaceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            editWorkspaceButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            editWorkspaceButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
