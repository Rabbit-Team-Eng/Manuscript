//
//  CardCellContentConfiguration.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import UIKit

struct CardCellContentConfiguration: UIContentConfiguration {
    
    var model: CardContentModel?
    weak var delegate: KaleidoscopeProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = CardCellContentView(configuration: self)
        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> CardCellContentConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}
