//
//  TaskEditCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/26/22.
//

import CoreData

struct TaskEditCoreDataRequest {
    let id: Int64
    let coreDataId: NSManagedObjectID
    let title: String
    let description: String
    let doeDate: String
    let ownerBoardId: Int64
    let status: String
    let priority: String
    let assigneeUserId: String
    let isInitiallySynced: Bool
    let isPendingDeletionOnTheServer: Bool

    init(id: Int64, coreDataId: NSManagedObjectID, title: String, description: String, doeDate: String, ownerBoardId: Int64, status: String, priority: String, assigneeUserId: String, isInitiallySynced: Bool, isPendingDeletionOnTheServer: Bool) {
        self.id = id
        self.coreDataId = coreDataId
        self.title = title
        self.description = description
        self.doeDate = doeDate
        self.ownerBoardId = ownerBoardId
        self.status = status
        self.priority = priority
        self.assigneeUserId = assigneeUserId
        self.isInitiallySynced = isInitiallySynced
        self.isPendingDeletionOnTheServer = isPendingDeletionOnTheServer
    }
    
    let workspaceId = Int64(UserDefaults.selectedWorkspaceId)!
    let lastModifiedDate = DateTimeUtils.convertDateToServerString(date: Date())

}
