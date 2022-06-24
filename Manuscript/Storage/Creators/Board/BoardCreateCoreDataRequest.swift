//
//  BoardCreateCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/23/22.
//

import CoreData

struct BoardCreateCoreDataRequest {
    
    let ownerWorkspaceCoreDataId: NSManagedObjectID
    let title: String
    let assetUrl: String
    
    init(ownerWorkspaceCoreDataId: NSManagedObjectID, title: String, assetUrl: String) {
        self.ownerWorkspaceCoreDataId = ownerWorkspaceCoreDataId
        self.title = title
        self.assetUrl = assetUrl
    }
    
    let ownerWorkspaceId: Int64 = Int64(UserDefaults.selectedWorkspaceId)!
    let detailDescription: String = ""
    let lastModifiedDate: String = DateTimeUtils.convertDateToServerString(date: .now)
    let id: Int64 = -1
    let isInitiallySynced: Bool = false
    let isPendingDeletionOnTheServer: Bool = false
}
