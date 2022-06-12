//
//  TaskEntity+CoreDataProperties.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var detail: String
    @NSManaged public var dueDate: String
    @NSManaged public var isInitiallySynced: Bool
    @NSManaged public var isPendingDeletionOnTheServer: Bool
    @NSManaged public var lastModifiedDate: String
    @NSManaged public var ownerBoardId: Int64
    @NSManaged public var remoteId: Int64
    @NSManaged public var status: String
    @NSManaged public var title: String
    @NSManaged public var workspaceId: Int64
    @NSManaged public var ownerBoard: BoardEntity?

}

extension TaskEntity : Identifiable {

}
