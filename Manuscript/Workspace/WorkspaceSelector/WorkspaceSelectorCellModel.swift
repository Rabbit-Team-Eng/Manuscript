//
//  WorkspaceSelectorCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import Foundation

struct WorkspaceSelectorCellModel: Hashable {
    let id: String
    let title: String
    var isEditable: Bool

    init(id: String, title: String, isEditable: Bool) {
        self.id = id
        self.title = title
        self.isEditable = isEditable
    }
}
