//
//  WorkspaceSelectorCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit

class WorkspaceSelectorCell: UICollectionViewListCell {
    
    var model: WorkspaceSelectorCellModel?
    weak var delegate: WorkspaceSelectorProtocol?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = WorkspaceSelectorContentConfiguration(model: model, delegate: delegate)
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
