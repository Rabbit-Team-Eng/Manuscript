//
//  BoardSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import CoreData
import Combine

class BoardSyncronizer: DataSyncronizer {
    
    typealias Model = BoardBusinessModel
    
    private let coreDataStack: CoreDataStack
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils
    private let boardCoreDataManager: BoardCoreDataManager

    init(coreDataStack: CoreDataStack, startupUtils: StartupUtils, boardCoreDataManager: BoardCoreDataManager) {
        self.coreDataStack = coreDataStack
        self.startupUtils = startupUtils
        self.boardCoreDataManager = boardCoreDataManager
    }
    
    func syncronize(items: [ComparatorResult<BoardBusinessModel>], completion: @escaping () -> Void) {
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { boardBusinessModelToBeInserted in
            insertIntoLocal(item: boardBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .update }.map { $0.businessObject }.forEach { boardBusinessModelToBeUpdated in
            updateIntoLocal(item: boardBusinessModelToBeUpdated)
        }
        
        items.filter { $0.target == .local && $0.operation == .removal }.map { $0.businessObject }.forEach { boardBusinessModelToBeDeleted in
            deleteIntoLocal(item: boardBusinessModelToBeDeleted)
        }
        completion()
    }
    
    private func insertIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
    }
    
    private func updateIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.updateIntoLocalInBackgrooundThread(item: item)
    }
    
    private func deleteIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.deleteInLocalOnBackgroundThread(item: item)
    }
    
    private func insertIntoServer(item: BoardBusinessModel) {
        
    }
    
    private func updateIntoServer(item: BoardBusinessModel) {
        
    }
    
    private func deleteIntoServer(item: BoardBusinessModel) {
        
    }
    
}
