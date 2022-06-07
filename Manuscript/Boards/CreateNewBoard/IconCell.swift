//
//  IconCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import UIKit

class IconCell: UICollectionViewCell {
    
    var model: IconCellModel?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = IconContentConfiguration(model: model)
        contentConfiguration = config
        
        if state.isSelected {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.lightBlack
            newBgConfiguration.cornerRadius = 13
            backgroundConfiguration = newBgConfiguration
        } else {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.gray
            backgroundConfiguration = newBgConfiguration
        }
    }
    
}
