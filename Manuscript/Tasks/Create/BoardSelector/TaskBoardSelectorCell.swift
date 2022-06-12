//
//  TaskBoardSelectorCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

class TaskBoardSelectorCell: UICollectionViewListCell {
    
    var model: TaskBoardSelectorCellModel?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = TaskBoardSelectorContentConfiguration(model: model)
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
