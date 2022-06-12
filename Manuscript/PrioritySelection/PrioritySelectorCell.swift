//
//  PrioritySelectorCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class PrioritySelectorCell: UICollectionViewCell {
    
    var model: PrioritySelectorCellModel?
    weak var delegate: PrioritySelectionActionsProtocol?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = PrioritySelectorContentConfiguration(model: model, delegate: delegate)
        contentConfiguration = config
        
        if state.isSelected {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.gray
            newBgConfiguration.cornerRadius = 13
            backgroundConfiguration = newBgConfiguration
        } else {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.lightBlack
            backgroundConfiguration = newBgConfiguration
        }
    }
    
}
