//
//  DatabaseItem.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Foundation

enum EntityType {
    case workspace
    case board
    case task
}

struct DatabaseItem: Hashable {
    let id: String
    let title: String
    let type: DatabaseSectionType
    let entityType: EntityType
}
