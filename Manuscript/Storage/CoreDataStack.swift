//
//  CoreDataStack.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 1/6/22.
//

import Foundation
import CoreData

public class CoreDataStack {
    
    private let databaseName: String

    public init() {
        self.databaseName = "TaskDB"
    }
    
    lazy var databaseContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.databaseName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data Container Failed: \(error)")
            }
        }
        return container
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        return databaseContainer.persistentStoreCoordinator
    }()
    
    lazy var mainThreadContext: NSManagedObjectContext = {
        return self.databaseContainer.viewContext
    }()
    
    func saveChangesIntoContext() {
        guard mainThreadContext.hasChanges else { return }
        do {
            try mainThreadContext.save()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
