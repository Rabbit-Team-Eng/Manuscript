//
//  File.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import UIKit

struct IconContentConfiguration: UIContentConfiguration {
    
    var model: IconCellModel?
    
    func makeContentView() -> UIView & UIContentView {
        let view = IconView(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> IconContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        let updatedConfiguration = self
        return updatedConfiguration
    }
    
    
}
