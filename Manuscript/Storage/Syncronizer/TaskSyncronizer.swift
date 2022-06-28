//
//  TaskSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Combine
import CoreData

class TaskSyncronizer: DataSyncronizer {
    
    typealias Model = TaskBusinessModel
    
    private let coreDataStack: CoreDataStack
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils
    private let taskCoreDataManager: TaskCoreDataManager
    private let taskService: TaskService

    init(coreDataStack: CoreDataStack, startupUtils: StartupUtils, taskCoreDataManager: TaskCoreDataManager, taskService: TaskService) {
        self.coreDataStack = coreDataStack
        self.startupUtils = startupUtils
        self.taskCoreDataManager = taskCoreDataManager
        self.taskService = taskService
    }
    
    func syncronize(items: [ComparatorResult<TaskBusinessModel>], completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            insertIntoLocal(item: taskBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .update }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            updateIntoLocal(item: taskBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .removal }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            deleteIntoLocal(item: taskBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .server && $0.operation == .insertion }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            group.enter()
            insertIntoServer(item: taskBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        items.filter { $0.target == .server && $0.operation == .removal }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            group.enter()
            insertIntoServer(item: taskBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        items.filter { $0.target == .server && $0.operation == .update }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            group.enter()
            deleteIntoServer(item: taskBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            completion()
        }
    }
    
    private func updateIntoServer(item: TaskBusinessModel, completion: @escaping () -> Void) {
        taskService.updateTaskById(requestBody: TaskRequest(boardId: item.ownerBoardId,
                                                            title: item.title,
                                                            detail: item.detail ?? "",
                                                            doeDate: item.dueDate,
                                                            assigneeId: item.assigneeUserId,
                                                            priority: PriorityTypeConverter.getString(priority: item.priority),
                                                            status: item.status),
                                                            taskId: "\(item.remoteId)")
        .sink { completion in } receiveValue: { taskResponse in
            let context = self.coreDataStack.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            
            context.performAndWait {
                if let coreDataId = item.coreDataId, let taskToBeUpdated = try? context.existingObject(with: coreDataId) as? TaskEntity {
                    taskToBeUpdated.lastModifiedDate = taskResponse.lastModifiedDate
                    taskToBeUpdated.isInitiallySynced = true

                    do {
                        try context.save()
                        completion()
                    } catch {
                        fatalError()
                    }

                }
            }
        }
        .store(in: &tokens)
    }
    
    private func insertIntoServer(item: TaskBusinessModel, completion: @escaping () -> Void) {
        taskService.createTask(requestBody: TaskRequest(boardId: item.ownerBoardId,
                                                        title: item.title,
                                                        detail: item.detail ?? "",
                                                        doeDate: item.dueDate,
                                                        assigneeId: item.assigneeUserId,
                                                        priority: "\(item.priority)",
                                                        status: item.status))
        .sink { completion in } receiveValue: { [weak self] taskResponse in
            guard let self = self, let coreDataId = item.coreDataId else { return }
            let context = self.coreDataStack.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            
            context.performAndWait {
                if let taskToBeUpdated = try? context.existingObject(with: coreDataId) as? TaskEntity {
                    taskToBeUpdated.remoteId = Int64(taskResponse.id)
                    taskToBeUpdated.lastModifiedDate = taskResponse.lastModifiedDate
                    taskToBeUpdated.isInitiallySynced = true
                    taskToBeUpdated.isPendingDeletionOnTheServer = false

                    
                    do {
                        try context.save()
                        completion()
                    } catch {
                        fatalError()
                    }
                }
            }
            
        }
        .store(in: &tokens)
    }
    
    private func deleteIntoServer(item: TaskBusinessModel, completion: @escaping () -> Void) {
        taskService.deleteTaskById(taskId: "\(item.remoteId)")
        .sink { completion in } receiveValue: { response in
            print(response)
            completion()
        }
        .store(in: &tokens)
    }
    
    private func insertIntoLocal(item: TaskBusinessModel) {
        taskCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
    }
    
    private func deleteIntoLocal(item: TaskBusinessModel) {
        taskCoreDataManager.deleteInLocalOnBackgroundThread(item: item)
    }
    
    private func updateIntoLocal(item: TaskBusinessModel) {
        taskCoreDataManager.updateIntoLocalInBackgrooundThread(item: item)
    }
    
    
    
}
