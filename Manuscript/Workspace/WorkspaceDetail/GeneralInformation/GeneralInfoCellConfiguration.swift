//
//  GeneralInformationCellConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import UIKit

struct GeneralInfoCellConfiguration: UIContentConfiguration {
    
    var model: WorksapceGeneralInfoCellModel?
    weak var delegate: WorkspaceDetailActionsProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = GeneralInfoContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> GeneralInfoCellConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
