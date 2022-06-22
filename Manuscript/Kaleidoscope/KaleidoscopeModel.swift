//
//  KaleidoscopeModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import Foundation

struct KaleidoscopeModel: Hashable {
    let id: String
    var section: KaleidoscopeSection
    var cardContentModel: CardContentModel?
    var inputCardContentModel: InputCardCellModel?

    init(id: String, section: KaleidoscopeSection, cardContentModel: CardContentModel) {
        self.id = id
        self.section = section
        self.cardContentModel = cardContentModel
        self.inputCardContentModel = nil
    }
    
    init(id: String, section: KaleidoscopeSection, inputCardContentModel: InputCardCellModel) {
        self.id = id
        self.section = section
        self.cardContentModel = nil
        self.inputCardContentModel = inputCardContentModel
    }
}


