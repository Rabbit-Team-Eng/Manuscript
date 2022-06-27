//
//  BoardBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct BoardBusinessModel: BusinessModelProtocol {

    public var coreDataId: NSManagedObjectID?
    public var ownerWorkspaceCoreDataId: NSManagedObjectID?
    
    public let assetUrl: String
    public let ownerWorkspaceId: Int64
    public let remoteId: Int64
    public let title: String
    public let detailDescription: String
    public let lastModifiedDate: Date
    public let isInitiallySynced: Bool
    public let isPendingDeletionOnTheServer: Bool
    public let tasks: [TaskBusinessModel]?
    
    public init(remoteId: Int64, coreDataId: NSManagedObjectID? = nil, ownerWorkspaceCoreDataId: NSManagedObjectID? = nil,  title: String, detailDescription: String, assetUrl: String, ownerWorkspaceId: Int64, lastModifiedDate: String, tasks: [TaskBusinessModel]? = nil, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.remoteId = remoteId
        self.assetUrl = assetUrl
        self.coreDataId = coreDataId
        self.ownerWorkspaceCoreDataId = ownerWorkspaceCoreDataId
        self.ownerWorkspaceId = ownerWorkspaceId
        self.title = title
        self.detailDescription = detailDescription
        self.lastModifiedDate = DateTimeUtils.convertServerStringToDate(stringDate: lastModifiedDate)
        self.tasks = tasks
        self.isInitiallySynced = isInitiallySynced
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer

    }
    
    public static func == (lhs: BoardBusinessModel, rhs: BoardBusinessModel) -> Bool {
        return lhs.remoteId == rhs.remoteId
        && lhs.ownerWorkspaceId == rhs.ownerWorkspaceId
        && lhs.assetUrl == rhs.assetUrl
        && lhs.title == rhs.title
        && lhs.lastModifiedDate == rhs.lastModifiedDate
        && lhs.isInitiallySynced == rhs.isInitiallySynced
        && lhs.isPendingDeletionOnTheServer == rhs.isPendingDeletionOnTheServer
    }
    
    public static func < (lhs: BoardBusinessModel, rhs: BoardBusinessModel) -> Bool {
        lhs.lastModifiedDate > rhs.lastModifiedDate
    }
}
