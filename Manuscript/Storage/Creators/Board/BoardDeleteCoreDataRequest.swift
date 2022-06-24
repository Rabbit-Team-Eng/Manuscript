//
//  BoardDeleteCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/23/22.
//

import CoreData

struct BoardDeleteCoreDataRequest {
    let id: Int64
    let coreDataId: NSManagedObjectID
    
    init(id: Int64, coreDataId: NSManagedObjectID) {
        self.id = id
        self.coreDataId = coreDataId
    }
    
    let lastModifiedDate: String = DateTimeUtils.convertDateToServerString(date: .now)
    let isInitiallySynced: Bool = true
    let isPendingDeletionOnTheServer: Bool = false
}
