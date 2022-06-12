//
//  TaskBoardSelectorContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

struct TaskBoardSelectorContentConfiguration: UIContentConfiguration {
    
    var model: TaskBoardSelectorCellModel?
    
    func makeContentView() -> UIView & UIContentView {
        let view = TaskBoardSelectorView(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TaskBoardSelectorContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfiguration = self
        return updatedConfiguration
    }
    
    
}
