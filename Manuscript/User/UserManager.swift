//
//  UserManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 7/2/22.
//

import Foundation

class UserManager {
    
    private let databaseManagaer: DatabaseManager
    private let startupUtils: StartupUtils

    init(databaseManagaer: DatabaseManager, startupUtils: StartupUtils) {
        self.databaseManagaer = databaseManagaer
        self.startupUtils = startupUtils
    }
    
    func signOut() {
        databaseManagaer.clearDatabase()
        startupUtils.deleteAcessToken()
        UserDefaults.selectedWorkspaceId = ""
        UserDefaults.userId = ""
    }
}
