//
//  TaskCreateCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/26/22.
//

import Foundation

struct TaskCreateCoreDataRequest {
    let title: String
    let description: String
    let doeDate: String
    let ownerBoardId: Int64
    let status: String
    let priority: String
    let assigneeUserId: String

    init(title: String, description: String, doeDate: String, ownerBoardId: Int64, status: String, priority: String, assigneeUserId: String) {
        self.title = title
        self.description = description
        self.doeDate = doeDate
        self.ownerBoardId = ownerBoardId
        self.status = status
        self.priority = priority
        self.assigneeUserId = assigneeUserId
    }
    
    let workspaceId = Int64(UserDefaults.selectedWorkspaceId)!
    let lastModifiedDate = DateTimeUtils.convertDateToServerString(date: Date())
    let isInitiallySynced = false
    let isPendingDeletionOnTheServer = false
}
