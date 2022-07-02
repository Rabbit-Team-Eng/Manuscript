//
//  SpaceCreateCoreDataRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 7/2/22.
//

import Foundation

struct SpaceCreateCoreDataRequest {
    let title: String
    let mainDescription: String

    init(title: String, mainDescription: String) {
        self.title = title
        self.mainDescription = mainDescription
    }

    let sharingEnabled = false
    let lastModifiedDate = DateTimeUtils.convertDateToServerString(date: Date())
    let isInitiallySynced = false
    let isPendingDeletionOnTheServer = false
}
