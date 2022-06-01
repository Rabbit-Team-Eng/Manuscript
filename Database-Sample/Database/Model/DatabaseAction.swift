//
//  DatabaseAction.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Foundation

enum DatabaseAction: Hashable {
    case createNewWorkspace
    case updateWorkspaceById(id: String, newTitle: String, entity: EntityType)
    case printEntityById(id: String, entity: EntityType)
    case updateBoardById
    case updateTaskById
}
