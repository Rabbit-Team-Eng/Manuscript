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
        NotificationCenter.default.addObserver(self, selector: #selector(newWorkspaceDidSwitched), name: Notification.Name("NewWorkspaceDidSwitched"), object: nil)

    }
    
    func fetchCurrentWorkspace() {

        if UserDefaults.selectedWorkspaceId == Constants.emptyString {
            let allWorkspaces = dataProvider.fetchAllWorkspacesOnMainThread()

            if let firstWorkspace = allWorkspaces.first {
                events.send(.titleDidFetch(title: firstWorkspace.title))
                UserDefaults.selectedWorkspaceId = "\(firstWorkspace.remoteId)"

                if  let boards = firstWorkspace.boards {
                    if boards.count == 0 {
                        events.send(.noBoardIsCreated)
                    } else {
                        events.send(.boardsDidFetch(boards: boards))
                    }
                }
            }
            
        } else {
            let selectedWorksapce = dataProvider.fetchWorkspaceByRemoteIdOnMainThread(id: UserDefaults.selectedWorkspaceId)
            
            if let firstWorkspace = selectedWorksapce {
                events.send(.titleDidFetch(title: firstWorkspace.title))
                UserDefaults.selectedWorkspaceId = "\(firstWorkspace.remoteId)"

                if let boards = firstWorkspace.boards {
                    if boards.count == 0 {
                        events.send(.noBoardIsCreated)
                    } else {
                        events.send(.boardsDidFetch(boards: boards))
                    }
                }
            }
        }
    }
    
    @objc func newWorkspaceDidSwitched() {
        fetchCurrentWorkspace()
    }
    
    @objc func cloudSyncDidFinish() {
        fetchCurrentWorkspace()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("CloudSyncDidFinish") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("NewWorkspaceDidSwitched") , object: nil)
    }
    
}
