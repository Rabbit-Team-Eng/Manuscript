//
//  TaskGeneralInfoCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

struct TaskGeneralInfoCellModel: Hashable {
    let title: String
    let description: String
    let isEditable: Bool
    let needPlaceholders: Bool
}
