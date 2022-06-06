//
//  DatabaseManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import CoreData

final class DatabaseManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func clearDatabase() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WorkspaceEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let boardFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BoardEntity")
        let boardDeleteRequest = NSBatchDeleteRequest(fetchRequest: boardFetchRequest)
        
        let memberFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MemberEntity")
        let memberDeleteRequest = NSBatchDeleteRequest(fetchRequest: memberFetchRequest)
        
        let taskFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TaskEntity")
        let taskDeleteRequest = NSBatchDeleteRequest(fetchRequest: taskFetchRequest)

        do {
            try coreDataStack.mainThreadContext.execute(deleteRequest)
            try coreDataStack.mainThreadContext.execute(boardDeleteRequest)
            try coreDataStack.mainThreadContext.execute(memberDeleteRequest)
            try coreDataStack.mainThreadContext.execute(taskDeleteRequest)
            coreDataStack.saveChangesIntoContext()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
