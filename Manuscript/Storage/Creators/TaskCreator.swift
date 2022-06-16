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
    
    private var tokens: Set<AnyCancellable> = []
    
    init(taskService: TaskService, database: CoreDataStack) {
        self.taskService = taskService
        self.database = database
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
                taskToBeUpdated.ownerBoardId = task.ownerBoardId
                
                if taskToBeUpdated.ownerBoardId != task.ownerBoardId {
                    
                    let newBoardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
                    newBoardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(task.ownerBoardId))")
                    
                    let oldBoardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
                    oldBoardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(taskToBeUpdated.ownerBoardId))")
                    
                    do {
                        
                        let newBoard: [BoardEntity] = try context.fetch(newBoardFetchRequest)
                        let newBoardEntity = newBoard.first!
                        newBoardEntity.addToTasks(taskToBeUpdated)
                        
                        let oldBoard: [BoardEntity] = try context.fetch(oldBoardFetchRequest)
                        let oldBoardEntity = oldBoard.first!
                        oldBoardEntity.removeFromTasks(taskToBeUpdated)
                        
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
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("TaskDidCreatedAndSyncedWithServer"), object: nil)
                        }
                    } catch {
                        fatalError()
                    }

                }
            }
        }
        .store(in: &tokens)

    }
    
    func createNewTask(task: TaskBusinessModel, completion: @escaping () -> Void) {
        
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let taskEntity = TaskEntity(context: context)
            

            taskEntity.assigneeUserId = task.assigneeUserId
            taskEntity.detail = task.detail ?? ""
            taskEntity.dueDate = task.dueDate
            taskEntity.isInitiallySynced = task.isInitiallySynced
            taskEntity.isPendingDeletionOnTheServer = task.isPendingDeletionOnTheServer
            taskEntity.ownerBoardId = task.ownerBoardId
            taskEntity.workspaceId = task.workspaceId
            taskEntity.remoteId = task.remoteId
            taskEntity.status = task.status
            taskEntity.title = task.title
            taskEntity.priority = PriorityTypeConverter.getString(priority: task.priority)
            taskEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: task.lastModifiedDate)

            
            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            boardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(taskEntity.ownerBoardId))")
            
            do {
                let boards: [BoardEntity] = try context.fetch(boardFetchRequest)
                let boardEntity = boards.first!
                boardEntity.addToTasks(taskEntity)
                try context.save()
                self.insertIntoServer(item: task, coreDataId: taskEntity.objectID)
                completion()
            } catch {
                fatalError()
            }
        }
    }
    
    private func insertIntoServer(item: TaskBusinessModel, coreDataId: NSManagedObjectID?) {
        
        taskService.createTask(requestBody: TaskRequest(boardId: item.ownerBoardId,
                                                        title: item.title,
                                                        detail: item.detail ?? "",
                                                        doeDate: item.dueDate,
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
                        self.notify()
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
