//
//  CardCell.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import UIKit

class CardCell: UICollectionViewListCell {
    
    var model: CardContentModel?
    weak var delegate: KaleidoscopeProtocol?

    override func updateConfiguration(using state: UICellConfigurationState) {
        
        let config = CardCellContentConfiguration(model: model, delegate: delegate)
        contentConfiguration = config
    }
    
}
