//
//  WorkspaceEntity+CoreDataProperties.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//
//

import Foundation
import CoreData


extension WorkspaceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkspaceEntity> {
        return NSFetchRequest<WorkspaceEntity>(entityName: "WorkspaceEntity")
    }

    @NSManaged public var isInitiallySynced: Bool
    @NSManaged public var isPendingDeletionOnTheServer: Bool
    @NSManaged public var lastModifiedDate: String
    @NSManaged public var mainDescription: String?
    @NSManaged public var remoteId: Int32
    @NSManaged public var sharingEnabled: Bool
    @NSManaged public var title: String
    @NSManaged public var boards: NSSet?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for boards
extension WorkspaceEntity {

    @objc(addBoardsObject:)
    @NSManaged public func addToBoards(_ value: BoardEntity)

    @objc(removeBoardsObject:)
    @NSManaged public func removeFromBoards(_ value: BoardEntity)

    @objc(addBoards:)
    @NSManaged public func addToBoards(_ values: NSSet)

    @objc(removeBoards:)
    @NSManaged public func removeFromBoards(_ values: NSSet)

}

// MARK: Generated accessors for members
extension WorkspaceEntity {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: MemberEntity)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: MemberEntity)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}

extension WorkspaceEntity : Identifiable {

}
