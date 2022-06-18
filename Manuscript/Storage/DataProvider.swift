//
//  WorkspaceDataManager.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData
import Combine

protocol Datasource {

    /// Use this method to query the Database in order to get all worksapces in the Database
    /// - Parameter thread: Chouse on which thread you want to perform the Database query
    /// - Returns: List of Worksapce Business Moderl Objects with all the boards, members and tasks
    func fetchWorkspaces(thread: Thread) -> [WorkspaceBusinessModel]
    
    
    
    /// Use this method to query the Database in order to a worksapces in the Database using its Id
    /// - Parameters:
    ///   - thread: Chouse on which thread you want to perform the Database query
    ///   - id: Server-Given Id
    /// - Returns: A Worksapce Business Moderl Object with all the boards, members and tasks
    func fetchWorkspace(thread: Thread, id: String) -> WorkspaceBusinessModel

    
    func fetchAllBoardsOnMainThread() -> [BoardBusinessModel]
    func fethAllBoardsOnBackgroundThread() -> [BoardBusinessModel]
    func fetchAllBoardsByWorkspaceIdOnMainThread(workspaceId: String) -> [BoardBusinessModel]
    
}

enum Thread {
    case main
    case background
}

class DataProvider: Datasource {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchWorkspace(thread: Thread, id: String) -> WorkspaceBusinessModel {
        var context: NSManagedObjectContext!
        var searchingWorkspace: WorkspaceBusinessModel!
        
        switch thread {
        case .main:
            context = coreDataStack.databaseContainer.viewContext
        case .background:
            context = coreDataStack.databaseContainer.newBackgroundContext()
        }
        
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(id))")
            
            do {
                let workspace: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                let worskpaceEntity = workspace.first!
                var allBoards: [BoardBusinessModel] = []
                var allMembers: [MemberBusinessModel] = []
                
                worskpaceEntity.boards?.forEach({ boardEntity in
                    
                    if let board = boardEntity as? BoardEntity {
                        var allTasks: [TaskBusinessModel] = []
                        
                        board.tasks?.forEach({ taskEntity in
                            if let task = taskEntity as? TaskEntity {
                                allTasks.append(TaskBusinessModel(remoteId: task.remoteId,
                                                                  coreDataId: task.objectID,
                                                                  ownerBoardCoreDataId: board.objectID,
                                                                  ownerWorkspaceCoreDataId: worskpaceEntity.objectID,
                                                                  assigneeUserId: task.assigneeUserId,
                                                                  title: task.title,
                                                                  detail: task.detail,
                                                                  dueDate: task.dueDate,
                                                                  ownerBoardId: task.ownerBoardId,
                                                                  status: task.status,
                                                                  workspaceId: task.workspaceId,
                                                                  lastModifiedDate: task.lastModifiedDate,
                                                                  isInitiallySynced: task.isInitiallySynced,
                                                                  isPendingDeletionOnTheServer: task.isInitiallySynced,
                                                                  priority: PriorityTypeConverter.getEnum(priority: task.priority)))
                            }
                        })
                        
                        allBoards.append(BoardBusinessModel(remoteId: board.remoteId,
                                                            coreDataId: board.objectID,
                                                            ownerWorkspaceCoreDataId: worskpaceEntity.objectID,
                                                            title: board.title,
                                                            detailDescription: board.mainDescription,
                                                            assetUrl: board.assetUrl,
                                                            ownerWorkspaceId: board.ownerWorkspaceId,
                                                            lastModifiedDate: board.lastModifiedDate,
                                                            tasks: allTasks,
                                                            isInitiallySynced: board.isInitiallySynced,
                                                            isPendingDeletionOnTheServer: board.isPendingDeletionOnTheServer))
                        
                    }
                    
                })
                
                worskpaceEntity.members?.forEach { memberEntity in
                    if let member = memberEntity as? MemberEntity {
                        allMembers.append(MemberBusinessModel(remoteId: member.remoteId,
                                                              ownerWorkspaceCoreDataId: worskpaceEntity.objectID,
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
                
                
                searchingWorkspace = WorkspaceBusinessModel(remoteId: worskpaceEntity.remoteId,
                                                           coreDataId: worskpaceEntity.objectID,
                                                           title: worskpaceEntity.title,
                                                           mainDescription: worskpaceEntity.mainDescription,
                                                           sharingEnabled: worskpaceEntity.sharingEnabled,
                                                           boards: allBoards,
                                                           members: allMembers,
                                                           lastModifiedDate: worskpaceEntity.lastModifiedDate,
                                                           isInitiallySynced: worskpaceEntity.isInitiallySynced,
                                                           isPendingDeletionOnTheServer: worskpaceEntity.isPendingDeletionOnTheServer)
                
                
            } catch {
                fatalError()
            }
        }

        return searchingWorkspace
        
    }
    
    func fetchWorkspaces(thread: Thread) -> [WorkspaceBusinessModel] {
        var context: NSManagedObjectContext!
        var allWorkspaces: [WorkspaceBusinessModel] = []
        
        switch thread {
        case .main:
            context = coreDataStack.databaseContainer.viewContext
        case .background:
            context = coreDataStack.databaseContainer.newBackgroundContext()
        }
        
        context.automaticallyMergesChangesFromParent = true
        
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
                                                                   coreDataId: task.objectID,
                                                                   ownerBoardCoreDataId: board.objectID,
                                                                   ownerWorkspaceCoreDataId: currentWorkspaceEntity.objectID,
                                                                   assigneeUserId: task.assigneeUserId,
                                                                   title: task.title,
                                                                   detail: task.detail,
                                                                   dueDate: task.dueDate,
                                                                   ownerBoardId: task.ownerBoardId,
                                                                   status: task.status,
                                                                   workspaceId: task.workspaceId,
                                                                   lastModifiedDate: task.lastModifiedDate,
                                                                   isInitiallySynced: task.isInitiallySynced,
                                                                   isPendingDeletionOnTheServer: task.isInitiallySynced,
                                                                   priority: PriorityTypeConverter.getEnum(priority: task.priority)))
                                }
                            }
                            
                            boards.append(BoardBusinessModel(remoteId: board.remoteId,
                                                             coreDataId: board.objectID,
                                                             ownerWorkspaceCoreDataId: currentWorkspaceEntity.objectID,
                                                             title: board.title,
                                                             detailDescription: board.mainDescription,
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
                                                               ownerWorkspaceCoreDataId: currentWorkspaceEntity.objectID,
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
    
    func fetchCurrentBoardWithRemoteId(id: String) -> BoardBusinessModel {
        
        let context = coreDataStack.databaseContainer.viewContext
        var returningBoard: BoardBusinessModel? = nil
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            boardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(id))")
            do {
                let boardEntity: BoardEntity = try context.fetch(boardFetchRequest).first!
                
                var allTasks: [TaskBusinessModel] = []
                
                boardEntity.tasks?.forEach({ taskEntity in
                    if let task = taskEntity as? TaskEntity {
                        allTasks.append(TaskBusinessModel(remoteId: task.remoteId,
                                                          coreDataId: task.objectID,
                                                          assigneeUserId: task.assigneeUserId,
                                                          title: task.title,
                                                          detail: task.detail,
                                                          dueDate: task.dueDate,
                                                          ownerBoardId: task.ownerBoardId,
                                                          status: task.status,
                                                          workspaceId: task.workspaceId,
                                                          lastModifiedDate: task.lastModifiedDate,
                                                          isInitiallySynced: task.isInitiallySynced,
                                                          isPendingDeletionOnTheServer: task.isInitiallySynced,
                                                          priority: PriorityTypeConverter.getEnum(priority: task.priority)))
                    }
                })
                
                let boardModel = BoardBusinessModel(remoteId: boardEntity.remoteId,
                                                    coreDataId: boardEntity.objectID,
                                                    title: boardEntity.title,
                                                    detailDescription: boardEntity.mainDescription,
                                                    assetUrl: boardEntity.assetUrl,
                                                    ownerWorkspaceId: boardEntity.ownerWorkspaceId,
                                                    lastModifiedDate: boardEntity.lastModifiedDate,
                                                    tasks: allTasks,
                                                    isInitiallySynced: boardEntity.isInitiallySynced,
                                                    isPendingDeletionOnTheServer: boardEntity.isPendingDeletionOnTheServer)
                returningBoard = boardModel
            } catch {
                
            }
        }
        return returningBoard!
    }
    
    func fetchCurrentBoardWithRemoteIdOnBackgroundThread(id: String) -> BoardBusinessModel {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        
        // If needed, ensure the background context stays
        // up to date with changes from the parent
        var returningBoard: BoardBusinessModel? = nil
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            boardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(id))")
            do {
                let boardEntity: BoardEntity = try context.fetch(boardFetchRequest).first!
                var allTasks: [TaskBusinessModel] = []
                
                boardEntity.tasks?.forEach({ taskEntity in
                    if let task = taskEntity as? TaskEntity {
                        allTasks.append(TaskBusinessModel(remoteId: task.remoteId,
                                                          coreDataId: task.objectID,
                                                          assigneeUserId: task.assigneeUserId,
                                                          title: task.title,
                                                          detail: task.detail,
                                                          dueDate: task.dueDate,
                                                          ownerBoardId: task.ownerBoardId,
                                                          status: task.status,
                                                          workspaceId: task.workspaceId,
                                                          lastModifiedDate: task.lastModifiedDate,
                                                          isInitiallySynced: task.isInitiallySynced,
                                                          isPendingDeletionOnTheServer: task.isInitiallySynced,
                                                          priority: PriorityTypeConverter.getEnum(priority: task.priority)))
                    }
                })
                
                let boardModel = BoardBusinessModel(remoteId: boardEntity.remoteId,
                                                    coreDataId: boardEntity.objectID,
                                                    title: boardEntity.title,
                                                    detailDescription: boardEntity.mainDescription,
                                                    assetUrl: boardEntity.assetUrl,
                                                    ownerWorkspaceId: boardEntity.ownerWorkspaceId,
                                                    lastModifiedDate: boardEntity.lastModifiedDate,
                                                    tasks: allTasks,
                                                    isInitiallySynced: boardEntity.isInitiallySynced,
                                                    isPendingDeletionOnTheServer: boardEntity.isPendingDeletionOnTheServer)
                returningBoard = boardModel
            } catch {
                fatalError()
            }
        }
        return returningBoard!
    }
    
   
    func fetchAllBoardsOnMainThread() -> [BoardBusinessModel] {
        var allBoardsModels: [BoardBusinessModel] = []
        let context = coreDataStack.databaseContainer.viewContext
        
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            do {
                let allBoards: [BoardEntity] = try context.fetch(boardFetchRequest)
                allBoards.forEach { boardEntity in
                    let boardsModel = BoardBusinessModel(remoteId: boardEntity.remoteId,
                                                         coreDataId: boardEntity.objectID,
                                                         title: boardEntity.title,
                                                         detailDescription: boardEntity.mainDescription,
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
    
    func fethAllBoardsOnBackgroundThread() -> [BoardBusinessModel] {
        var allBoardsModels: [BoardBusinessModel] = []
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        
        // If needed, ensure the background context stays
        // up to date with changes from the parent
        context.automaticallyMergesChangesFromParent = true
        
        // Perform operations on the background context asynchronously
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            do {
                let allBoards: [BoardEntity] = try context.fetch(boardFetchRequest)
                allBoards.forEach { boardEntity in
                    let boardsModel = BoardBusinessModel(remoteId: boardEntity.remoteId,
                                                         coreDataId: boardEntity.objectID,
                                                         title: boardEntity.title, detailDescription: boardEntity.mainDescription,
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
    
    func fethAllTasksOnBackgroundThread() -> [TaskBusinessModel] {
        var allTasksModels: [TaskBusinessModel] = []
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        
        // If needed, ensure the background context stays
        // up to date with changes from the parent
        context.automaticallyMergesChangesFromParent = true
        
        // Perform operations on the background context asynchronously
        context.performAndWait {
            let boardFetchRequest: NSFetchRequest<TaskEntity> = NSFetchRequest(entityName: "TaskEntity")
            do {
                let allTasks: [TaskEntity] = try context.fetch(boardFetchRequest)
                allTasks.forEach { taskEntity in
                    let taskModel = TaskBusinessModel(remoteId: taskEntity.remoteId,
                                                      coreDataId: taskEntity.objectID,
                                                      assigneeUserId: taskEntity.assigneeUserId,
                                                      title: taskEntity.title,
                                                      detail: taskEntity.detail,
                                                      dueDate: taskEntity.dueDate,
                                                      ownerBoardId: taskEntity.ownerBoardId,
                                                      status: taskEntity.status,
                                                      workspaceId: taskEntity.workspaceId,
                                                      lastModifiedDate: taskEntity.lastModifiedDate,
                                                      isInitiallySynced: taskEntity.isInitiallySynced,
                                                      isPendingDeletionOnTheServer: taskEntity.isPendingDeletionOnTheServer,
                                                      priority: PriorityTypeConverter.getEnum(priority: taskEntity.priority))
                    
                    allTasksModels.append(taskModel)
                    
                }
            } catch {
                
            }
        }
        
        return allTasksModels
        
    }
    
    
    func fetchAllBoardsByWorkspaceIdOnMainThread(workspaceId: String) -> [BoardBusinessModel] {
        var returningBoards: [BoardBusinessModel] = []
        let mainThread = coreDataStack.mainThreadContext
        let boardsFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
        boardsFetchRequest.predicate = NSPredicate(format: "ownerWorkspaceId == %@", "\(workspaceId))")
        
        do {
            returningBoards = try mainThread.fetch(boardsFetchRequest).map({ boardEntity in
                BoardBusinessModel(remoteId: boardEntity.remoteId,
                                   coreDataId: boardEntity.objectID,
                                   title: boardEntity.title,
                                   detailDescription: boardEntity.mainDescription,
                                   assetUrl: boardEntity.assetUrl,
                                   ownerWorkspaceId: boardEntity.ownerWorkspaceId,
                                   lastModifiedDate: boardEntity.lastModifiedDate,
                                   isInitiallySynced: boardEntity.isInitiallySynced,
                                   isPendingDeletionOnTheServer: boardEntity.isPendingDeletionOnTheServer)
            })
        } catch {
            
        }
        
        return returningBoards
    }
}
