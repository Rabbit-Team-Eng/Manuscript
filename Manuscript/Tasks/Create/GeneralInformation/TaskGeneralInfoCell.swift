//
//  TaskGeneralInfoCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

class TaskGeneralInfoCell: UICollectionViewCell {
    
    var model: TaskGeneralInfoCellModel?
    weak var delegate: TaskCreateActionProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = TaskGeneralInfoConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
