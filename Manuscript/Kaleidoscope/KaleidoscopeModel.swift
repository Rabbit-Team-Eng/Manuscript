//
//  KaleidoscopeModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import Foundation

struct KaleidoscopeModel: Hashable {
    let id: String
    let cardContentModel: CardContentModel?
    
    init(id: String, cardContentModel: CardContentModel) {
        self.id = id
        self.cardContentModel = cardContentModel
    }
}


