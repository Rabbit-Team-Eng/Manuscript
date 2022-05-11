//
//  DatabaseItem.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Foundation

struct DatabaseItem: Hashable {
    let id: String
    let title: String
    let action: DatabaseAction
    let type: DatabaseSectionType
}
