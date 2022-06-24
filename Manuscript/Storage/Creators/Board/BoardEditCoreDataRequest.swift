//
//  BoardEditCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/23/22.
//

import CoreData

struct BoardEditCoreDataRequest {
    let id: Int64
    let coreDataId: NSManagedObjectID
    let title: String
    let assetUrl: String
    
    init(id: Int64, coreDataId: NSManagedObjectID, title: String, assetUrl: String) {
        self.id = id
        self.coreDataId = coreDataId
        self.title = title
        self.assetUrl = assetUrl
    }
    
    let ownerWorkspaceId: Int64 = Int64(UserDefaults.selectedWorkspaceId)!
    let detailDescription: String = ""
    let lastModifiedDate: String = DateTimeUtils.convertDateToServerString(date: .now)
    let isInitiallySynced: Bool = true
    let isPendingDeletionOnTheServer: Bool = false
}
