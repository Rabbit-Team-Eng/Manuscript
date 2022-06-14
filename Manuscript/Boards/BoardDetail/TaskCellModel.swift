//
//  TaskCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Foundation

struct TaskCellModel: Hashable {
    let id: String
    let title: String
    let description: String
    var priority: Priority
    let assignee: String
    let status: String
    let boardTitle: String
}
