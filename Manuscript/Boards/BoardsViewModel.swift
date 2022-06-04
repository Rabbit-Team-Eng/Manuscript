//
//  BoardsViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Combine
import UIKit

enum BoardsViewControllerEvent {
    case titleDidFetch(title: String)
    case boardsDidFetch(boards: [BoardBusinessModel])
    case noBoardIsCreated
}

class BoardsViewModel {
    
    private let dataProvider: DataProvider
    let events: PassthroughSubject<BoardsViewControllerEvent, Never> = PassthroughSubject()

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider

        NotificationCenter.default.addObserver(self, selector: #selector(cloudSyncDidFinish), name: Notification.Name("CloudSyncDidFinish"), object: nil)

    }
    
    func fetchCurrentWorkspace() {

        if UserDefaults.selectedWorkspaceId == Constants.emptyString {
            let allWorkspaces = dataProvider.fetchAllWorkspacesOnMainThread()

            if let firstWorkspace = allWorkspaces.first {
                if  let boards = firstWorkspace.boards {
                    UserDefaults.selectedWorkspaceId = "\(firstWorkspace.remoteId)"
                    events.send(.titleDidFetch(title: firstWorkspace.title))
                    events.send(.boardsDidFetch(boards: boards))
                } else {
                    events.send(.noBoardIsCreated)
                }

            }
            
        } else {
            let selectedWorksapce = dataProvider.fetchWorkspaceByRemoteIdOnMainThread(id: UserDefaults.selectedWorkspaceId)
            
            if let firstWorkspace = selectedWorksapce {
                if let boards = firstWorkspace.boards {
                    UserDefaults.selectedWorkspaceId = "\(firstWorkspace.remoteId)"
                    events.send(.titleDidFetch(title: firstWorkspace.title))
                    events.send(.boardsDidFetch(boards: boards))
                } else {
                    events.send(.noBoardIsCreated)
                }
            }
        }
    }
    
    @objc func cloudSyncDidFinish() {
        fetchCurrentWorkspace()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("CloudSyncDidFinish") , object: nil)
    }
    
}
