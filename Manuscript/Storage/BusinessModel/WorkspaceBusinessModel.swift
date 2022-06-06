//
//  WorkspaceBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct WorkspaceBusinessModel: BusinessModelProtocol {

    public let mainDescription: String?
    public let remoteId: Int32
    public var coreDataId: NSManagedObjectID?
    public let lastModifiedDate: Date
    public let isInitiallySynced: Bool
    public let isPendingDeletionOnTheServer: Bool
    public let sharingEnabled: Bool
    public let title: String
    public let boards: [BoardBusinessModel]?
    public let members: [MemberBusinessModel]?
    
    public init(remoteId: Int32, coreDataId: NSManagedObjectID? = nil, title: String, mainDescription: String? = nil, sharingEnabled: Bool, boards: [BoardBusinessModel]? = nil, members: [MemberBusinessModel]? = nil, lastModifiedDate: String, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.remoteId = remoteId
        self.coreDataId = coreDataId
        self.title = title
        self.mainDescription = mainDescription ?? ""
        self.sharingEnabled = sharingEnabled
        self.boards = boards
        self.members = members
        self.lastModifiedDate = DateTimeUtils.convertServerStringToDate(stringDate: lastModifiedDate)
        self.isInitiallySynced = isInitiallySynced
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer
    }
    
    public static func < (lhs: WorkspaceBusinessModel, rhs: WorkspaceBusinessModel) -> Bool {
        lhs.remoteId < rhs.remoteId
    }
    
    public static func == (lhs: WorkspaceBusinessModel, rhs: WorkspaceBusinessModel) -> Bool {
        return lhs.remoteId == rhs.remoteId
        && lhs.title == rhs.title
        && lhs.sharingEnabled == rhs.sharingEnabled
        && lhs.mainDescription == rhs.mainDescription
        && lhs.lastModifiedDate == rhs.lastModifiedDate
        && lhs.isPendingDeletionOnTheServer == rhs.isPendingDeletionOnTheServer
        && lhs.isInitiallySynced == rhs.isInitiallySynced
    }
}
