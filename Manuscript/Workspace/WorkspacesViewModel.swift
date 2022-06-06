//
//  WorkspacesViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/6/22.
//

import Combine
import UIKit

enum WorkspaceSelectorViewControllerEvent {
    case workspacesDidFetch(workspaces: [WorkspaceBusinessModel])
}

class WorkspacesViewModel {
    
    private let dataProvider: DataProvider
    let events: PassthroughSubject<WorkspaceSelectorViewControllerEvent, Never> = PassthroughSubject()

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider

        NotificationCenter.default.addObserver(self, selector: #selector(cloudSyncDidFinish), name: Notification.Name("CloudSyncDidFinish"), object: nil)

    }
    
    @objc func cloudSyncDidFinish() {
        fetchWorkspaces()
    }
    
    func fetchWorkspaces() {
        let allWorkspaces = dataProvider.fetchAllWorkspacesOnMainThread()
        events.send(.workspacesDidFetch(workspaces: allWorkspaces))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("CloudSyncDidFinish") , object: nil)
    }
}
