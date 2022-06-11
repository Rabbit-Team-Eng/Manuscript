//
//  ManageAcessCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

class ManageAccessCell: UICollectionViewCell {
  
    var model: ManageAcessCellModel?
    weak var delegate: WorkspaceDetailActionsProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = ManageAccessConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}
