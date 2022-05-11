//
//  SingleButtonCellConfiguration.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import UIKit

struct SingleButtonCellConfiguration: UIContentConfiguration {
    
    var model: DatabaseItem?
    weak var delegate: DatabaseEventProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = SingleButtonContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> SingleButtonCellConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
