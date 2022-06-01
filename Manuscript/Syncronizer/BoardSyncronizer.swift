//
//  BoardSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import CoreData
import Combine

class BoardSyncronizer: DataSyncronizer {
    
    private let coreDataStack: CoreDataStack
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils

    init(coreDataStack: CoreDataStack, startupUtils: StartupUtils) {
        self.coreDataStack = coreDataStack
        self.startupUtils = startupUtils
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
    }
    
    func insertIntoLocal(item: BoardBusinessModel) {
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            let boardCoreDataEntity = BoardEntity(context: context)
            boardCoreDataEntity.remoteId = item.remoteId
            boardCoreDataEntity.title = item.title
            boardCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            boardCoreDataEntity.assetUrl = item.assetUrl
            boardCoreDataEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            boardCoreDataEntity.isInitiallySynced = item.isInitiallySynced
            boardCoreDataEntity.ownerWorkspaceId = item.ownerWorkspaceId
            do {
                try context.save()
            } catch {
                fatalError()
            }
        
        }
    }
    
    func updateIntoLocal(item: BoardBusinessModel) {
        
    }
    
    func deleteIntoLocal(item: BoardBusinessModel) {
        
    }
    
    func insertIntoServer(item: BoardBusinessModel) {
        
    }
    
    func updateIntoServer(item: BoardBusinessModel) {
        
    }
    
    func deleteIntoServer(item: BoardBusinessModel) {
        
    }
    
    typealias Model = BoardBusinessModel
    
    
}
