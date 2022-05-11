//
//  TaskBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct TaskBusinessModel: BusinessModelProtocol {
    public var coreDataId: NSManagedObjectID? = nil

    public let remoteId: Int32
    public let title: String
    public var isInitiallySynced: Bool
    public let lastModifiedDate: Date
    public let detail: String?
    public let dueDate: String
    public let ownerBoardId: Int32
    public let status: String
    public let workspaceId: Int32
    public let isPendingDeletionOnTheServer: Bool

    public init(remoteId: Int32, title: String, detail: String?, dueDate: String, ownerBoardId: Int32, status: String, workspaceId: Int32, lastModifiedDate: String, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.remoteId = remoteId
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.ownerBoardId = ownerBoardId
        self.status = status
        self.workspaceId = workspaceId
        self.isInitiallySynced = isInitiallySynced
        self.lastModifiedDate = DateTimeUtils.convertServerStringToDate(stringDate: lastModifiedDate)
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer
    }
    
    public static func < (lhs: TaskBusinessModel, rhs: TaskBusinessModel) -> Bool {
        lhs.remoteId < rhs.remoteId
    }
    
}
