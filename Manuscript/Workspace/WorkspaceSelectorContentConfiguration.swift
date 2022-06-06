//
//  WorkspaceSelectorContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit

protocol WorkspaceSelectorProtocol: NSObject {
    func workspaceDetailFlowDidSelected(model: WorkspaceSelectorCellModel)
}

struct WorkspaceSelectorContentConfiguration: UIContentConfiguration {
    
    var model: WorkspaceSelectorCellModel?
    weak var delegate: WorkspaceSelectorProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = WorkspaceSelectorView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> WorkspaceSelectorContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfiguration = self
        
        if state.isSelected {
            updatedConfiguration.model?.isEditable = true
        } else {
            updatedConfiguration.model?.isEditable = false
        }
        return updatedConfiguration
    }
    
    
}
