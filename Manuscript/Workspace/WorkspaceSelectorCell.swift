//
//  WorkspaceSelectorCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit

class WorkspaceSelectorCell: UICollectionViewListCell {
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        if state.isSelected {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.lightGray
            newBgConfiguration.cornerRadius = 13
            backgroundConfiguration = newBgConfiguration
        } else {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.lightBlack
            backgroundConfiguration = newBgConfiguration
        }

        
    }
    
}
