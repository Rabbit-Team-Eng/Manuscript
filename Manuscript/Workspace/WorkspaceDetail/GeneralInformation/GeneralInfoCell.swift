//
//  GeneralInformationCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

class GeneralInfoCell: UICollectionViewCell {
    
    var model: WorksapceGeneralInfoCellModel?
    weak var delegate: WorkspaceDetailActionsProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = GeneralInfoCellConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
