//
//  TaskSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Combine

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
        
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { taskBusinessModelToBeInserted in
            insertIntoLocal(item: taskBusinessModelToBeInserted)
        }
        completion()
    }
    
    private func insertIntoLocal(item: TaskBusinessModel) {
        taskCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
    }
    
}
