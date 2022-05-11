//
//  BoardEntity+CoreDataProperties.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//
//

import Foundation
import CoreData


extension BoardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoardEntity> {
        return NSFetchRequest<BoardEntity>(entityName: "BoardEntity")
    }

    @NSManaged public var assetUrl: String
    @NSManaged public var isInitiallySynced: Bool
    @NSManaged public var isPendingDeletionOnTheServer: Bool
    @NSManaged public var lastModifiedDate: String
    @NSManaged public var ownerWorkspaceId: Int32
    @NSManaged public var remoteId: Int32
    @NSManaged public var title: String
    @NSManaged public var ownerWorkspace: WorkspaceEntity?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension BoardEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension BoardEntity : Identifiable {

}
