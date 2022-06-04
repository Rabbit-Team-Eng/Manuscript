//
//  WorkspaceCoreDataManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Combine
import CoreData

class WorkspaceCoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func insertIntoLocalOnBackgroundThread(item: WorkspaceBusinessModel) {
        let context = self.coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.performAndWait {
            let workspaceCoreDataEntity = WorkspaceEntity(context: context)
            workspaceCoreDataEntity.remoteId = item.remoteId
            workspaceCoreDataEntity.title = item.title
            workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            workspaceCoreDataEntity.isInitiallySynced = item.isInitiallySynced
            workspaceCoreDataEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            workspaceCoreDataEntity.mainDescription = item.mainDescription
            workspaceCoreDataEntity.sharingEnabled = item.sharingEnabled
            do {
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    func updateIntoLocalInBackgrooundThread(item: WorkspaceBusinessModel) {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
           
            if let objectId = item.coreDataId, let workspaceCoreDataEntity = try? context.existingObject(with: objectId) as? WorkspaceEntity {
                workspaceCoreDataEntity.title = item.title
                workspaceCoreDataEntity.mainDescription = item.mainDescription
                workspaceCoreDataEntity.sharingEnabled = item.sharingEnabled
                workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
                do {
                    try context.save()
                } catch {
                    fatalError("updateIntoLocal")
                }
            }
        }
        
    }
    
    func deleteInLocalOnBackgroundThread(item: WorkspaceBusinessModel) {
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            if let objectId = item.coreDataId, let workspaceCoreDataEntity = try? context.existingObject(with: objectId) as? WorkspaceEntity {
                context.delete(workspaceCoreDataEntity)
                do {
                    try context.save()
                } catch {
                    fatalError()
                }
            }
        }
    }
    
}
