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
    
    func editTask(task: TaskBusinessModel, completion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            if let coreDataId = task.coreDataId, let taskToBeUpdated = try? context.existingObject(with: coreDataId) as? TaskEntity {
                taskToBeUpdated.title = task.title
                taskToBeUpdated.detail = task.detail ?? ""
                taskToBeUpdated.dueDate = task.dueDate
                taskToBeUpdated.assigneeUserId = task.assigneeUserId
                taskToBeUpdated.status = task.status
                taskToBeUpdated.priority = PriorityTypeConverter.getString(priority: task.priority)
                
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
                    completion()
                    editTaskInServer(taskId: task.remoteId,
                                          ownerBoardId: task.ownerBoardId,
                                          title: task.title,
                                          detail: task.detail ?? "",
                                          doeDate: task.dueDate,
                                          priority: PriorityTypeConverter.getString(priority: task.priority),
                                          assigneeId: task.assigneeUserId,
                                          status: task.status,
                                          coreDataId: task.coreDataId)
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func editTaskInServer(taskId: Int64, ownerBoardId: Int64, title: String, detail: String, doeDate: String, priority: String, assigneeId: String, status: String, coreDataId: NSManagedObjectID?) {
        
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
                    
                    do {
                        try context.save()
                        let currentMembers = self.dataProvider.fetchWorkspace(thread: .background, id: "\(taskResponse.workspaceId)").members?.compactMap { $0.remoteId }

                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("TaskDidCreatedAndSyncedWithServer"), object: nil)
//                            self.signalRManager.broadcastMessage(enity: "board", id: taskResponse.id, action: "create", members: currentMembers!)

                        }
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
    
    func removeBoard(task: TaskBusinessModel, completion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            if let coreDataId = task.coreDataId, let taskToBeRemoved = try? context.existingObject(with: coreDataId) as? TaskEntity {
                taskToBeRemoved.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: task.lastModifiedDate)
                taskToBeRemoved.isPendingDeletionOnTheServer = task.isPendingDeletionOnTheServer
                
                do {
                    context.delete(taskToBeRemoved)
                    try context.save()
                    completion()
                    self.removeFromServer(taskId: task.remoteId, ownerWorkspaceId: task.workspaceId, coreDataId: coreDataId)
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func removeFromServer(taskId: Int64, ownerWorkspaceId: Int64, coreDataId: NSManagedObjectID?) {
        taskService.deleteTaskById(taskId: "\(taskId)")
            .sink { completion in } receiveValue: { removedId in
                
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = coreDataId, let taskToBeRemoved = try? context.existingObject(with: coreDataId) as? TaskEntity {
                       
                        context.delete(taskToBeRemoved)
                        do {
                            try context.save()
                            let currentMembers = self.dataProvider.fetchWorkspace(thread: .background, id: "\(ownerWorkspaceId)").members?.compactMap { $0.remoteId }

                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("CloudSyncDidFinish"), object: nil)
//                                self.signalRManager.broadcastMessage(enity: "board", id: Int(ownerWorkspaceId), action: "create", members: currentMembers!)

                            }
                        } catch {
                            fatalError()
                        }
                    }
                }
                
            }
            .store(in: &tokens)
    }
    
    
    private func notify() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("TaskDidCreatedAndSyncedWithServer"), object: nil)
        }
    }
}
