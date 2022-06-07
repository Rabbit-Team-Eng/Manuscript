//
//  IconCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import Foundation

struct IconSelectorCellModel: Hashable {
    let id: String
    let iconResource: String
    
    init(id: String, iconResource: String) {
        self.id = id
        self.iconResource = iconResource
    }
}
