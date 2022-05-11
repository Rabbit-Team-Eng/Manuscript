//
//  SingleButtonCell.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import UIKit

class SingleButtonCell: UICollectionViewCell {
    
    var model: DatabaseItem?
    weak var delegate: DatabaseEventProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = SingleButtonCellConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
