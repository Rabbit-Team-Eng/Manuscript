//
//  File.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import UIKit

struct IconSelectorContentConfiguration: UIContentConfiguration {
    
    var model: IconSelectorCellModel?
    
    func makeContentView() -> UIView & UIContentView {
        let view = IconSelectorView(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> IconSelectorContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        let updatedConfiguration = self
        return updatedConfiguration
    }
    
    
}
