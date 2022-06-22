//
//  InputCellContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/20/22.
//

import UIKit

struct InputCellContentConfiguration: UIContentConfiguration {
    
    var model: InputCardCellModel?
    weak var delegate: KaleidoscopeProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = InputCellContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> InputCellContentConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
