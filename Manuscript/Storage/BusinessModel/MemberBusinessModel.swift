//
//  MemberBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct MemberBusinessModel: BusinessModelProtocol {
    public var coreDataId: NSManagedObjectID? = nil
    
    public var remoteId: Int32
    public let firstName: String
    public let lastName: String
    public let avatarUrl: String
    public let email: String
    public let isWorkspaceOwner: Bool
    public let isInitiallySynced: Bool
    public let ownerWorkspaceId: Int32
    public let lastModifiedDate: Date
    public let isPendingDeletionOnTheServer: Bool

    public init(remoteId: Int32, firstName: String, lastName: String, avatarUrl: String, email: String, isWorkspaceOwner: Bool, ownerWorkspaceId: Int32, lastModifiedDate: String, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.remoteId = remoteId
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
        self.email = email
        self.isWorkspaceOwner = isWorkspaceOwner
        self.ownerWorkspaceId = ownerWorkspaceId
        self.lastModifiedDate = DateTimeUtils.convertServerStringToDate(stringDate: lastModifiedDate)
        self.isInitiallySynced = isInitiallySynced
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer
    }
    
    public static func < (lhs: MemberBusinessModel, rhs: MemberBusinessModel) -> Bool {
        lhs.remoteId < rhs.remoteId
    }
    
    public static func == (lhs: MemberBusinessModel, rhs: MemberBusinessModel) -> Bool {
        return lhs.remoteId == rhs.remoteId
    }
    
    
}
