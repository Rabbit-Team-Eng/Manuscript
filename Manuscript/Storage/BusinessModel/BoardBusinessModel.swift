//
//  BoardBusinessModel.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/22/22.
//

import Foundation
import CoreData

public struct BoardBusinessModel: BusinessModelProtocol {

    public let assetUrl: String
    public let ownerWorkspaceId: Int32
    public let remoteId: Int32
    public let title: String
    public var coreDataId: NSManagedObjectID?
    public let lastModifiedDate: Date
    public let isInitiallySynced: Bool
    public let isPendingDeletionOnTheServer: Bool
    public let tasks: [TaskBusinessModel]?
    
    public init(remoteId: Int32, coreDataId: NSManagedObjectID? = nil, title: String, assetUrl: String, ownerWorkspaceId: Int32, lastModifiedDate: String, tasks: [TaskBusinessModel]? = nil, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.remoteId = remoteId
        self.assetUrl = assetUrl
        self.coreDataId = coreDataId
        self.ownerWorkspaceId = ownerWorkspaceId
        self.title = title
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
