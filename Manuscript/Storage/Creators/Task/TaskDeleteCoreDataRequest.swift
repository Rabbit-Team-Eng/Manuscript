//
//  TaskDeleteCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/27/22.
//

import CoreData

struct TaskDeleteCoreDataRequest {
    let id: Int64
    let coreDataId: NSManagedObjectID
    let isInitiallySynced: Bool
    
    init(id: Int64, coreDataId: NSManagedObjectID, isInitiallySynced: Bool) {
        self.id = id
        self.coreDataId = coreDataId
        self.isInitiallySynced = isInitiallySynced
    }
    
    let lastModifiedDate: String = DateTimeUtils.convertDateToServerString(date: .now)
    let isPendingDeletionOnTheServer: Bool = true
}
