//
//  BoardsFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum BoardsFlow: Flowable {

    case boards
    case boardsDetail


    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .boards:
            return "thesis://main/boards"
        case .boardsDetail:
            return "thesis://main/boards?id=mock_id"
        }

    }
}
