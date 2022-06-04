//
//  BoardsViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class BoardsViewModel {
    
    private let dataProvider: DataProvider
    private let cloudSync: CloudSync

    init(dataProvider: DataProvider, cloudSync: CloudSync) {
        self.dataProvider = dataProvider
        self.cloudSync = cloudSync
        
        print("Already in DB: \(dataProvider.fetchAllWorkspacesOnMainThread())")
        
        cloudSync.syncronize()

        NotificationCenter.default.addObserver(self, selector: #selector(cloudSyncDidFinish), name: Notification.Name("CloudSyncDidFinish"), object: nil)

    }
    
    @objc func cloudSyncDidFinish() {
        print("cloudSyncDidFinish")
        print("After the Sync: \(dataProvider.fetchAllWorkspacesOnMainThread())")
    }
    
    func fetchBoards() {
        let x = dataProvider.fetchAllBoardsByWorkspaceIdOnMainThread(workspaceId: UserDefaults.selectedWorkspace)
        print(x)
    }
    
}
