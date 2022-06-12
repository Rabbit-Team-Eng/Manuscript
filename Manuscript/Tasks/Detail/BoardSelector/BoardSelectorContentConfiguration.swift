//
//  TaskBoardSelectorContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

struct BoardSelectorContentConfiguration: UIContentConfiguration {
    
    var model: BoardSelectorCellModel?
    
    func makeContentView() -> UIView & UIContentView {
        let view = BoardSelectorView(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> BoardSelectorContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfiguration = self
        return updatedConfiguration
    }
    
    
}
