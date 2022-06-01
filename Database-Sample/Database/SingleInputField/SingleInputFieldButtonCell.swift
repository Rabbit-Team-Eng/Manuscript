//
//  SingleInputFieldButtonCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/11/22.
//

import Foundation

import UIKit

class SingleInputFieldButtonCell: UICollectionViewCell {
    
    var model: DatabaseItem?
    weak var delegate: DatabaseEventProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = SingleInputFieldCellConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
