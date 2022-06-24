//
//  BoardCreateCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/23/22.
//

import Foundation

struct BoardCreateCoreDataRequest {
    let title: String
    let assetUrl: String
    
    init(title: String, assetUrl: String) {
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
