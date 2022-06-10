//
//  GeneralInfoSectionHeaderView.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

class GeneralInfoSectionHeaderView: UICollectionReusableView {
    
    static var reuseIdentifier: String { return String(describing: GeneralInfoSectionHeaderView.self) }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textColor = Palette.blue
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Palette.lightBlack
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
