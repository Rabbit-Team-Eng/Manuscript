//
//  PrioritySelectorContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

struct PrioritySelectorContentConfiguration: UIContentConfiguration {
    
    var model: PrioritySelectorCellModel?
    weak var delegate: PrioritySelectionActionsProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = PrioritySelectorContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> PrioritySelectorContentConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
