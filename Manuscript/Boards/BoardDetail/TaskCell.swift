//
//  TaskCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class TaskCell: UICollectionViewCell {
    
    var model: TaskCellModel?
    weak var delegate: TaskCellProtocol?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = TaskCellContentConfiguration(model: model, delegate: delegate)
        contentConfiguration = config
    }
    
}
