//
//  InputCardCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/20/22.
//

import UIKit

class InputCardCell: UICollectionViewListCell {
    
    var model: InputCardCellModel?
    weak var delegate: KaleidoscopeProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = InputCellContentConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
