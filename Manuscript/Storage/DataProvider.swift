//
//  WorkspaceDataManager.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

class DataProvider {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }


    func getAllWorkspacesInBackground() -> [WorkspaceBusinessModel] {
        var allWorkspaces: [WorkspaceBusinessModel] = []
        
        coreDataStack.databaseContainer.performBackgroundTask { childContext in
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            do {
                let allWorkspaceEntities: [WorkspaceEntity] = try childContext.fetch(workspacesFetchRequest)
                allWorkspaceEntities.forEach { currentWorkspaceEntity in
                    var members: [MemberBusinessModel] = []
                    var boards: [BoardBusinessModel] = []

                    currentWorkspaceEntity.boards?.forEach { boardEntity in
                        if let board = boardEntity as? BoardEntity {
                            var tasks: [TaskBusinessModel] = []
                            
                            board.tasks?.forEach { taskEntity in
                                if let task = taskEntity as? TaskEntity {
                                    tasks.append(TaskBusinessModel(remoteId: task.remoteId,
                                                                   title: task.title,
                                                                   detail: task.detail,
                                                                   dueDate: task.dueDate,
                                                                   ownerBoardId: task.ownerBoardId,
                                                                   status: task.status,
                                                                   workspaceId: task.workspaceId,
                                                                   lastModifiedDate: task.lastModifiedDate,
                                                                   isInitiallySynced: task.isInitiallySynced,
                                                                   isPendingDeletionOnTheServer: task.isInitiallySynced))
                                }
                            }
                            
                            boards.append(BoardBusinessModel(remoteId: board.remoteId,
                                                             coreDataId: board.objectID,
                                                             title: board.title,
                                                             assetUrl: board.assetUrl,
                                                             ownerWorkspaceId: board.ownerWorkspaceId,
                                                             lastModifiedDate: board.lastModifiedDate,
                                                             tasks: tasks,
                                                             isInitiallySynced: board.isInitiallySynced,
                                                             isPendingDeletionOnTheServer: board.isPendingDeletionOnTheServer))
                        }
                    }
                    
                    currentWorkspaceEntity.members?.forEach { memberEntity in
                        if let member = memberEntity as? MemberEntity {
                            members.append(MemberBusinessModel(remoteId: member.remoteId,
                                                               firstName: member.firstName,
                                                               lastName: member.lastName,
                                                               avatarUrl: member.avatarUrl,
                                                               email: member.email,
                                                               isWorkspaceOwner: member.isWorkspaceOwner,
                                                               ownerWorkspaceId: member.ownerWorkspaceId,
                                                               lastModifiedDate: member.lastModifiedDate,
                                                               isInitiallySynced: member.isInitiallySynced,
                                                               isPendingDeletionOnTheServer: member.isPendingDeletionOnTheServer)
                            )
                        }
                    }
                    
                    let currentWorkspaceBusinessModel = WorkspaceBusinessModel(remoteId: currentWorkspaceEntity.remoteId,
                                                                               coreDataId: currentWorkspaceEntity.objectID,
                                                                               title: currentWorkspaceEntity.title,
                                                                               mainDescription: currentWorkspaceEntity.mainDescription,
                                                                               sharingEnabled: currentWorkspaceEntity.sharingEnabled,
                                                                               boards: boards,
                                                                               members: members,
                                                                               lastModifiedDate: currentWorkspaceEntity.lastModifiedDate,
                                                                               isInitiallySynced: currentWorkspaceEntity.isInitiallySynced,
                                                                               isPendingDeletionOnTheServer: currentWorkspaceEntity.isPendingDeletionOnTheServer)
                    
                    allWorkspaces.append(currentWorkspaceBusinessModel)
                }
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
        

        return allWorkspaces


    }
    
    func getAllBoardsAsyncBlock() -> [BoardBusinessModel] {
        var allBoardsModels: [BoardBusinessModel] = []
        let context = coreDataStack.databaseContainer.newBackgroundContext()

        // If needed, ensure the background context stays
        // up to date with changes from the parent
        context.automaticallyMergesChangesFromParent = true

        // Perform operations on the background context
        // asynchronously
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            do {
                let allBoards: [BoardEntity] = try context.fetch(boardFetchRequest)
                allBoards.forEach { boardEntity in
                    let boardsModel = BoardBusinessModel(remoteId: boardEntity.remoteId,
                                                         coreDataId: boardEntity.objectID,
                                                         title: boardEntity.title,
                                                         assetUrl: boardEntity.assetUrl,
                                                         ownerWorkspaceId: boardEntity.ownerWorkspaceId,
                                                         lastModifiedDate: boardEntity.lastModifiedDate,
                                                         isInitiallySynced: boardEntity.isInitiallySynced,
                                                         isPendingDeletionOnTheServer: boardEntity.isPendingDeletionOnTheServer)
                    allBoardsModels.append(boardsModel)
                    
                }
            } catch {
                
            }
        }
        
        return allBoardsModels
        
    }
    
    public func getAllWorkspacesAsyncBlock() -> [WorkspaceBusinessModel] {
        var allWorkspaces: [WorkspaceBusinessModel] = []
        let context = coreDataStack.databaseContainer.newBackgroundContext()

        // If needed, ensure the background context stays
        // up to date with changes from the parent
        context.automaticallyMergesChangesFromParent = true

        // Perform operations on the background context
        // asynchronously
        context.performAndWait {
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            do {
                let allWorkspaceEntities: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                allWorkspaceEntities.forEach { currentWorkspaceEntity in
                    var members: [MemberBusinessModel] = []
                    var boards: [BoardBusinessModel] = []

                    currentWorkspaceEntity.boards?.forEach { boardEntity in
                        if let board = boardEntity as? BoardEntity {
                            var tasks: [TaskBusinessModel] = []
                            
                            board.tasks?.forEach { taskEntity in
                                if let task = taskEntity as? TaskEntity {
                                    tasks.append(TaskBusinessModel(remoteId: task.remoteId,
                                                                   title: task.title,
                                                                   detail: task.detail,
                                                                   dueDate: task.dueDate,
                                                                   ownerBoardId: task.ownerBoardId,
                                                                   status: task.status,
                                                                   workspaceId: task.workspaceId,
                                                                   lastModifiedDate: task.lastModifiedDate,
                                                                   isInitiallySynced: task.isInitiallySynced,
                                                                   isPendingDeletionOnTheServer: task.isInitiallySynced))
                                }
                            }
                            
                            boards.append(BoardBusinessModel(remoteId: board.remoteId,
                                                             coreDataId: board.objectID,
                                                             title: board.title,
                                                             assetUrl: board.assetUrl,
                                                             ownerWorkspaceId: board.ownerWorkspaceId,
                                                             lastModifiedDate: board.lastModifiedDate,
                                                             tasks: tasks,
                                                             isInitiallySynced: board.isInitiallySynced,
                                                             isPendingDeletionOnTheServer: board.isPendingDeletionOnTheServer))
                        }
                    }
                    
                    currentWorkspaceEntity.members?.forEach { memberEntity in
                        if let member = memberEntity as? MemberEntity {
                            members.append(MemberBusinessModel(remoteId: member.remoteId,
                                                               firstName: member.firstName,
                                                               lastName: member.lastName,
                                                               avatarUrl: member.avatarUrl,
                                                               email: member.email,
                                                               isWorkspaceOwner: member.isWorkspaceOwner,
                                                               ownerWorkspaceId: member.ownerWorkspaceId,
                                                               lastModifiedDate: member.lastModifiedDate,
                                                               isInitiallySynced: member.isInitiallySynced,
                                                               isPendingDeletionOnTheServer: member.isPendingDeletionOnTheServer)
                            )
                        }
                    }
                    
                    let currentWorkspaceBusinessModel = WorkspaceBusinessModel(remoteId: currentWorkspaceEntity.remoteId,
                                                                               coreDataId: currentWorkspaceEntity.objectID,
                                                                               title: currentWorkspaceEntity.title,
                                                                               mainDescription: currentWorkspaceEntity.mainDescription,
                                                                               sharingEnabled: currentWorkspaceEntity.sharingEnabled,
                                                                               boards: boards,
                                                                               members: members,
                                                                               lastModifiedDate: currentWorkspaceEntity.lastModifiedDate,
                                                                               isInitiallySynced: currentWorkspaceEntity.isInitiallySynced,
                                                                               isPendingDeletionOnTheServer: currentWorkspaceEntity.isPendingDeletionOnTheServer)
                    
                    allWorkspaces.append(currentWorkspaceBusinessModel)
                }
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
        return allWorkspaces
    }
    
}
