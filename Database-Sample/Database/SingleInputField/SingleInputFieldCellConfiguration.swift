//
//  SingleInputFieldCellConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/11/22.
//

import UIKit

struct SingleInputFieldCellConfiguration: UIContentConfiguration {
    
    var model: DatabaseItem?
    weak var delegate: DatabaseEventProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = SingleInputFieldContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> SingleInputFieldCellConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
