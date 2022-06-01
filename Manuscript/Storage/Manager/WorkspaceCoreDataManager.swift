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
    
    func insertIntoLocalAsyncBlocking(item: WorkspaceBusinessModel) {
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
    
    func updateIntoLocalAsyncBlocking(item: WorkspaceBusinessModel) {
        
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
    
    func deleteIntoLocalAsyncBlocking(item: WorkspaceBusinessModel) {
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
    
    func getWorkspaceByIdSync(id: Int) -> WorkspaceBusinessModel? {
        var searchingWorkspace: WorkspaceBusinessModel? = nil
        
        let context = coreDataStack.databaseContainer.viewContext

        context.performAndWait {
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(id))")
            
            do {
                let workspace: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                let worskpaceEntity = workspace.first!
                searchingWorkspace = WorkspaceBusinessModel(remoteId: worskpaceEntity.remoteId,
                                                            coreDataId: worskpaceEntity.objectID,
                                                            title: worskpaceEntity.title,
                                                            mainDescription: worskpaceEntity.mainDescription,
                                                            sharingEnabled: worskpaceEntity.sharingEnabled,
                                                            lastModifiedDate: worskpaceEntity.lastModifiedDate,
                                                            isInitiallySynced: worskpaceEntity.isInitiallySynced,
                                                            isPendingDeletionOnTheServer: worskpaceEntity.isPendingDeletionOnTheServer)
            } catch {
                fatalError()
            }
        }
        
        return searchingWorkspace
    }
}
