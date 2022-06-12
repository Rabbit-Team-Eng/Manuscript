//
//  MemberEntity+CoreDataProperties.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//
//

import Foundation
import CoreData


extension MemberEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemberEntity> {
        return NSFetchRequest<MemberEntity>(entityName: "MemberEntity")
    }

    @NSManaged public var avatarUrl: String
    @NSManaged public var email: String
    @NSManaged public var firstName: String
    @NSManaged public var isInitiallySynced: Bool
    @NSManaged public var isPendingDeletionOnTheServer: Bool
    @NSManaged public var isWorkspaceOwner: Bool
    @NSManaged public var lastModifiedDate: String
    @NSManaged public var lastName: String
    @NSManaged public var ownerWorkspaceId: Int64
    @NSManaged public var remoteId: Int64
    @NSManaged public var ownerWorkspace: WorkspaceEntity?

}

extension MemberEntity : Identifiable {

}
