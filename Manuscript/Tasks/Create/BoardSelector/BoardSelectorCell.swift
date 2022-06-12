//
//  TaskBoardSelectorCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

class BoardSelectorCell: UICollectionViewListCell {
    
    var model: BoardSelectorCellModel?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = BoardSelectorContentConfiguration(model: model)
        contentConfiguration = config
        
        if state.isSelected {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.gray
            newBgConfiguration.cornerRadius = 9
            backgroundConfiguration = newBgConfiguration
        } else {
            var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell()
            newBgConfiguration.backgroundColor = Palette.lightBlack
            backgroundConfiguration = newBgConfiguration
        }
    }
    
}
