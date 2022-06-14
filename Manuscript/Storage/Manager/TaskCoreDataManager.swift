//
//  TaskCoreDataManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import CoreData

class TaskCoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func insertIntoLocalOnBackgroundThread(item: TaskBusinessModel) {
        let context = self.coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let taskEntity = TaskEntity(context: context)

            taskEntity.assigneeUserId = item.assigneeUserId
            taskEntity.detail = item.detail ?? ""
            taskEntity.dueDate = item.dueDate
            taskEntity.isInitiallySynced = item.isInitiallySynced
            taskEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            taskEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            taskEntity.ownerBoardId = item.ownerBoardId
            taskEntity.remoteId = item.remoteId
            taskEntity.status = item.status
            taskEntity.title = item.title
            taskEntity.workspaceId = item.workspaceId
            taskEntity.priority = PriorityTypeConverter.getString(priority: item.priority)

            let boardFetchRequest: NSFetchRequest<BoardEntity> = NSFetchRequest(entityName: "BoardEntity")
            boardFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(item.ownerBoardId))")
            
            do {
                let board: [BoardEntity] = try context.fetch(boardFetchRequest)
                let boardEntity = board.first!
                boardEntity.addToTasks(taskEntity)
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
}
