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
    
    func createNewTask(task: TaskBusinessModel, completion: @escaping () -> Void) {
        
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let taskEntity = TaskEntity(context: context)
            

            taskEntity.detail = task.detail ?? ""
            taskEntity.dueDate = task.dueDate
            taskEntity.isInitiallySynced = task.isInitiallySynced
            taskEntity.isPendingDeletionOnTheServer = task.isPendingDeletionOnTheServer
            taskEntity.ownerBoardId = task.ownerBoardId
            taskEntity.remoteId = task.remoteId
            taskEntity.status = task.status
            taskEntity.title = task.title
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
                                                        doeDate: nil,
                                                        assigneeId: item.assigneeUserId))
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
