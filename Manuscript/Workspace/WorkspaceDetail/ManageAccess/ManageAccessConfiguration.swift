//
//  ManageAccessConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

struct ManageAccessConfiguration: UIContentConfiguration {
    
    var model: ManageAcessCellModel?
    weak var delegate: WorkspaceDetailActionsProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = ManageAccessContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> ManageAccessConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
