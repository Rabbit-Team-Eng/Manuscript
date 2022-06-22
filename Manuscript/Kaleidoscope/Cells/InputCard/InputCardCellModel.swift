//
//  InputCardCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/20/22.
//

import Foundation

struct InputCardCellModel: Hashable {
    let firstText: String
    let firstPlaceholder: String?
    let firstIsInteractionsEnabled: Bool
    
    let secondText: String
    let secondPlaceholder: String?
    let secondIsInteractionsEnabled: Bool
}
