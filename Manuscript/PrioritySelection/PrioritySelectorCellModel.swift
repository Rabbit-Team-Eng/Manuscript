//
//  PrioritySelectorCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Foundation

struct PrioritySelectorCellModel: Hashable {
    let title: String
    let description: String
    var priority: Priority
    let isHighlighted: Bool
}
