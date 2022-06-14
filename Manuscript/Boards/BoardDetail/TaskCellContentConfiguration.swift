//
//  TaskCellContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

struct TaskCellContentConfiguration: UIContentConfiguration {
    
    var model: TaskCellModel?
    weak var delegate: TaskCellProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = TaskCellContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TaskCellContentConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
