//
//  BoardTransformer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import Foundation


struct BoardTransformer {
    
    static func transformBoardsToCellModel(boards: [BoardBusinessModel]) -> [BoardCellModel] {
        return boards.sorted().map { BoardCellModel(remoteId: "\($0.remoteId)",
                                                    boardTitle: $0.title,
                                                    numberOfTasks: $0.tasks?.count ?? 0,
                                                    imageIcon: $0.assetUrl,
                                                    isSynced: $0.isInitiallySynced) }
    }
}
