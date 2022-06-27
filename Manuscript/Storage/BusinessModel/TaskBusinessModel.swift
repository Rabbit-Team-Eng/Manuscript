//
//  TaskBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct TaskBusinessModel: BusinessModelProtocol {
    public var coreDataId: NSManagedObjectID?
    public var ownerBoardCoreDataId: NSManagedObjectID?
    public var ownerWorkspaceCoreDataId: NSManagedObjectID?

    public let remoteId: Int64
    public let assigneeUserId: String
    public let title: String
    public var isInitiallySynced: Bool
    public let lastModifiedDate: Date
    public let detail: String?
    public let dueDate: String
    public let ownerBoardId: Int64
    public let status: String
    public let workspaceId: Int64
    public let isPendingDeletionOnTheServer: Bool
    public let priority: Priority

    public init(remoteId: Int64, coreDataId: NSManagedObjectID? = nil, ownerBoardCoreDataId: NSManagedObjectID? = nil, ownerWorkspaceCoreDataId: NSManagedObjectID? = nil, assigneeUserId: String, title: String, detail: String?, dueDate: String, ownerBoardId: Int64, status: String, workspaceId: Int64, lastModifiedDate: String, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool, priority: Priority) {
        self.remoteId = remoteId
        self.coreDataId = coreDataId
        self.ownerBoardCoreDataId = ownerBoardCoreDataId
        self.ownerWorkspaceCoreDataId = ownerWorkspaceCoreDataId
        self.assigneeUserId = assigneeUserId
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.ownerBoardId = ownerBoardId
        self.status = status
        self.workspaceId = workspaceId
        self.isInitiallySynced = isInitiallySynced
        self.lastModifiedDate = DateTimeUtils.convertServerStringToDate(stringDate: lastModifiedDate)
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer
        self.priority = priority
    }
    
    public static func == (lhs: TaskBusinessModel, rhs: TaskBusinessModel) -> Bool {
        return lhs.remoteId == rhs.remoteId
        && lhs.assigneeUserId == rhs.assigneeUserId
        && lhs.title == rhs.title
        && lhs.isInitiallySynced == rhs.isInitiallySynced
        && lhs.lastModifiedDate == rhs.lastModifiedDate
        && lhs.detail == rhs.detail
//        && lhs.dueDate == rhs.dueDate
        && lhs.ownerBoardId == rhs.ownerBoardId
        && lhs.status == rhs.status
        && lhs.workspaceId == rhs.workspaceId
        && lhs.isPendingDeletionOnTheServer == rhs.isPendingDeletionOnTheServer
        && lhs.priority == rhs.priority

    }
    
    public static func < (lhs: TaskBusinessModel, rhs: TaskBusinessModel) -> Bool {
        lhs.lastModifiedDate > rhs.lastModifiedDate
    }
    
}
