//
//  TaskCreator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//


import CoreData
import Combine


class TaskCreator {
    
    private let taskService: TaskService
    private let database: CoreDataStack
    private let signalRManager: SignalRManager
    private let dataProvider: DataProvider

    private var tokens: Set<AnyCancellable> = []
    
    init(taskService: TaskService, database: CoreDataStack, signalRManager: SignalRManager, dataProvider: DataProvider) {
        self.taskService = taskService
        self.signalRManager = signalRManager
        self.database = database
        self.dataProvider = dataProvider
    }
    
    func editTask(task: TaskEditCoreDataRequest, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            if let taskToBeUpdated = try? context.existingObject(with: task.coreDataId) as? TaskEntity {
                taskToBeUpdated.title = task.title
                taskToBeUpdated.detail = task.description
                taskToBeUpdated.dueDate = task.doeDate
                taskToBeUpdated.assigneeUserId = task.assigneeUserId
                taskToBeUpdated.status = task.status
                taskToBeUpdated.priority = task.priority
                taskToBeUpdated.isInitiallySynced = task.isInitiallySynced
                taskToBeUpdated.isPendingDeletionOnTheServer = task.isPendingDeletionOnTheServer

                
                if taskToBeUpdated.ownerBoardId != task.ownerBoardId {

                    let newBoardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
                    newBoardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(task.ownerBoardId))")
                    taskToBeUpdated.ownerBoardId = task.ownerBoardId

                    do {
                        let newBoard: [BoardEntity] = try context.fetch(newBoardFetchRequest)
                        let newBoardEntity = newBoard.first!
                        taskToBeUpdated.ownerBoard = newBoardEntity
                    } catch {
                        fatalError()
                    }
                }
                
                do {
                    try context.save()
                    databaseCompletion()
                    editTaskInServer(taskId: task.id,
                                          ownerBoardId: task.ownerBoardId,
                                          title: task.title,
                                          detail: task.description,
                                          doeDate: task.doeDate,
                                          priority: task.priority,
                                          assigneeId: task.assigneeUserId,
                                          status: task.status,
                                     coreDataId: task.coreDataId) {
                        serverCompletion()
                    }
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func editTaskInServer(taskId: Int64, ownerBoardId: Int64, title: String, detail: String, doeDate: String, priority: String, assigneeId: String, status: String, coreDataId: NSManagedObjectID?, serverCompletion: @escaping () -> Void) {
        
        taskService.updateTaskById(requestBody: TaskRequest(boardId: ownerBoardId,
                                                            title: title,
                                                            detail: detail,
                                                            doeDate: doeDate,
                                                            assigneeId: assigneeId,
                                                            priority: priority,
                                                            status: status),
                                                            taskId: "\(taskId)")
        .sink { completion in } receiveValue: { taskResponse in
            let context = self.database.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            
            context.performAndWait {
                if let coreDataId = coreDataId, let taskToBeUpdated = try? context.existingObject(with: coreDataId) as? TaskEntity {
                    taskToBeUpdated.lastModifiedDate = taskResponse.lastModifiedDate
                    taskToBeUpdated.isInitiallySynced = true

                    do {
                        try context.save()
                        serverCompletion()
                    } catch {
                        fatalError()
                    }

                }
            }
        }
        .store(in: &tokens)

    }
    
    func createNewTask(task: TaskCreateCoreDataRequest, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let taskEntity = TaskEntity(context: context)
            

            taskEntity.assigneeUserId = task.assigneeUserId
            taskEntity.detail = task.description
            taskEntity.dueDate = task.doeDate
            taskEntity.isInitiallySynced = task.isInitiallySynced
            taskEntity.isPendingDeletionOnTheServer = task.isPendingDeletionOnTheServer
            taskEntity.ownerBoardId = task.ownerBoardId
            taskEntity.workspaceId = task.workspaceId
            taskEntity.remoteId = -1
            taskEntity.status = task.status
            taskEntity.title = task.title
            taskEntity.priority = task.priority
            taskEntity.lastModifiedDate = task.lastModifiedDate

            
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            boardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(taskEntity.ownerBoardId))")
            
            do {
                let boards: [BoardEntity] = try context.fetch(boardFetchRequest)
                let boardEntity = boards.first!
                boardEntity.addToTasks(taskEntity)
                try context.save()
                databaseCompletion()
                self.insertIntoServer(item: task, coreDataId: taskEntity.objectID) {
                    serverCompletion()
                }
            } catch {
                fatalError()
            }
        }
    }
    
    private func insertIntoServer(item: TaskCreateCoreDataRequest, coreDataId: NSManagedObjectID?, serverCompletion: @escaping () -> Void) {
        
        taskService.createTask(requestBody: TaskRequest(boardId: item.ownerBoardId,
                                                        title: item.title,
                                                        detail: item.description,
                                                        doeDate: item.doeDate,
                                                        assigneeId: item.assigneeUserId,
                                                        priority: "\(item.priority)",
                                                        status: item.status))
        .sink { completion in } receiveValue: { [weak self] taskResponse in
            guard let self = self, let coreDataId = coreDataId else { return }
            let context = self.database.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            
            context.performAndWait {
                if let taskToBeUpdated = try? context.existingObject(with: coreDataId) as? TaskEntity {
                    taskToBeUpdated.remoteId = Int64(taskResponse.id)
                    taskToBeUpdated.lastModifiedDate = taskResponse.lastModifiedDate
                    taskToBeUpdated.isInitiallySynced = true
                    taskToBeUpdated.isPendingDeletionOnTheServer = false

                    
                    do {
                        try context.save()
                        serverCompletion()
                    } catch {
                        fatalError()
                    }
                }
            }
            
        }
        .store(in: &tokens)

    }
    
    func removeTask(task: TaskDeleteCoreDataRequest, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            if let taskToBeRemoved = try? context.existingObject(with: task.coreDataId) as? TaskEntity {
                taskToBeRemoved.lastModifiedDate = task.lastModifiedDate
                var needToBeRemovedFromServer = false
                
                if task.isInitiallySynced {
                    needToBeRemovedFromServer = true
                }
                do {
                    context.delete(taskToBeRemoved)
     
                    try context.save()
                    databaseCompletion()
                    if needToBeRemovedFromServer {
                        self.removeFromServer(taskId: task.id, coreDataId: task.coreDataId) {
                            serverCompletion()
                        }
                    }
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func removeFromServer(taskId: Int64, coreDataId: NSManagedObjectID?, serverCompletion: @escaping () -> Void) {
        taskService.deleteTaskById(taskId: "\(taskId)")
            .sink { completion in } receiveValue: { removedId in
                
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = coreDataId, let taskToBeRemoved = try? context.existingObject(with: coreDataId) as? TaskEntity {
                       
                        context.delete(taskToBeRemoved)
                        do {
                            try context.save()
                            serverCompletion()
                        } catch {
                            fatalError()
                        }
                    }
                }
                
            }
            .store(in: &tokens)
    }
    
}
