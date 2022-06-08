//
//  BoardCoreDataManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import Combine
import CoreData

class BoardCoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func insertIntoLocalOnBackgroundThread(item: BoardBusinessModel) {
        let context = self.coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardEntity = BoardEntity(context: context)
            boardEntity.assetUrl = item.assetUrl
            boardEntity.isInitiallySynced = item.isInitiallySynced
            boardEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            boardEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            boardEntity.ownerWorkspaceId = item.ownerWorkspaceId
            boardEntity.remoteId = item.remoteId
            boardEntity.title = item.title
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(item.ownerWorkspaceId))")
            
            do {
                let workspace: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                let worskpaceEntity = workspace.first!
                worskpaceEntity.addToBoards(boardEntity)
                try context.save()
                print("DEBUG_LOG: Saved the Item Into Core Data!")
            } catch {
                fatalError()
            }
        }
    }
    
    func updateIntoLocalInBackgrooundThread(item: BoardBusinessModel) {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
           
            if let objectId = item.coreDataId, let boardEntity = try? context.existingObject(with: objectId) as? BoardEntity {
                boardEntity.title = item.title
                boardEntity.assetUrl = item.assetUrl
                boardEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
                do {
                    try context.save()
                } catch {
                    fatalError("updateIntoLocal")
                }
            }
        }
        
    }
    
    func deleteInLocalOnBackgroundThread(item: BoardBusinessModel) {
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            if let objectId = item.coreDataId, let boardEntity = try? context.existingObject(with: objectId) as? BoardEntity {
                context.delete(boardEntity)
                do {
                    try context.save()
                } catch {
                    fatalError()
                }
            }
        }
    }
    
}
