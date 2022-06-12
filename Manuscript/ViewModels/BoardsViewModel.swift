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
    case newBoardDidCreated
    case boardDetailDidFetch(board: BoardBusinessModel)
}

class BoardsViewModel {
    
    private let dataProvider: DataProvider
    private let boardCreator: BoardCreator
    private let cloudSync: CloudSync
    let events: PassthroughSubject<BoardsViewControllerEvent, Never> = PassthroughSubject()

    init(dataProvider: DataProvider, boardCreator: BoardCreator, cloudSync: CloudSync) {
        self.dataProvider = dataProvider
        self.boardCreator = boardCreator
        self.cloudSync = cloudSync

        NotificationCenter.default.addObserver(self, selector: #selector(cloudSyncDidFinish), name: Notification.Name("CloudSyncDidFinish"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newWorkspaceDidSwitched), name: Notification.Name("NewWorkspaceDidSwitched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(boardDidCreatedAndSyncedWithServer), name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
    }
    
    func syncTheCloud() {
        cloudSync.syncronize()
    }
    
    func fetchCurrentBoard(id: String) {
        let board = dataProvider.fetchCurrentBoardWithRemoteId(id: id)
        events.send(.boardDetailDidFetch(board: board))
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
            
            events.send(.titleDidFetch(title: selectedWorksapce.title))
            UserDefaults.selectedWorkspaceId = "\(selectedWorksapce.remoteId)"

            if let boards = selectedWorksapce.boards {
                if boards.count == 0 {
                    events.send(.noBoardIsCreated)
                } else {
                    events.send(.boardsDidFetch(boards: boards))
                }
            }
        }
    }
    
    func createNewBoard(title: String, icon: String, ownerWorkspaceId: Int64) {
        let newBoard = BoardBusinessModel(remoteId: -990,
                                          title: title,
                                          assetUrl: icon,
                                          ownerWorkspaceId: ownerWorkspaceId,
                                          lastModifiedDate: DateTimeUtils.convertDateToServerString(date: Date()),
                                          isInitiallySynced: false,
                                          isPendingDeletionOnTheServer: false)
        
        boardCreator.createNewBoard(board: newBoard) { [weak self] in guard let self = self else { return }
            self.events.send(.newBoardDidCreated)
            self.fetchCurrentWorkspace()
        }
    }
    
    func createNewTask() {
        
    }
    
    @objc func boardDidCreatedAndSyncedWithServer() {
        fetchCurrentWorkspace()
    }
    
    @objc func newWorkspaceDidSwitched() {
        fetchCurrentWorkspace()
    }
    
    @objc private func cloudSyncDidFinish() {
        fetchCurrentWorkspace()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("CloudSyncDidFinish") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("NewWorkspaceDidSwitched") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("BoardDidCreatedAndSyncedWithServer") , object: nil)

    }
    
}
