//
//  TaskGeneralInfoConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import UIKit

struct TaskGeneralInfoConfiguration: UIContentConfiguration {
    
    var model: TaskGeneralInfoCellModel?
    weak var delegate: TaskCreateActionProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = TaskGeneralInfoContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TaskGeneralInfoConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
