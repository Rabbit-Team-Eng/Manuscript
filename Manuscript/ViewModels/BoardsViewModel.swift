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
    case currentBoardDidEdit(board: BoardBusinessModel)
    case currentBoardDidRemoved
    case taskJustCreatedLocally(board: BoardBusinessModel)
    case taskJustEditedLocally(board: BoardBusinessModel)
    case boardDetailDidFetch(board: BoardBusinessModel)
}

class BoardsViewModel {
    
    private let dataProvider: DataProvider
    private let boardCreator: BoardCreator
    private let taskCreator: TaskCreator
    private let cloudSync: CloudSync
    let events: PassthroughSubject<BoardsViewControllerEvent, Never> = PassthroughSubject()
    
    public var selectedPriority: PrioritySelectorCellModel? = nil
    
    let priorirtySetEvenet: PassthroughSubject<Priority, Never> = PassthroughSubject()


    init(dataProvider: DataProvider, boardCreator: BoardCreator, taskCreator: TaskCreator, cloudSync: CloudSync) {
        self.dataProvider = dataProvider
        self.boardCreator = boardCreator
        self.taskCreator = taskCreator
        self.cloudSync = cloudSync
        
        NotificationCenter.default.addObserver(self, selector: #selector(cloudSyncDidFinish), name: Notification.Name("CloudSyncDidFinish"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newWorkspaceDidSwitched), name: Notification.Name("NewWorkspaceDidSwitched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(boardDidCreatedAndSyncedWithServer), name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(taskDidCreatedAndSyncedWithServer), name: Notification.Name("TaskDidCreatedAndSyncedWithServer"), object: nil)
    }
    
    func syncTheCloud() {
        cloudSync.syncronize()
    }
    
    func newPriorityDidSet(priority: Priority) {
        priorirtySetEvenet.send(priority)
    }
    
    func fetchCurrentBoard(id: String) {
        let board = dataProvider.fetchCurrentBoardWithRemoteId(id: id)
        events.send(.boardDetailDidFetch(board: board))
    }
    
    func fetchCurrentWorkspace() {

        if UserDefaults.selectedWorkspaceId == Constants.emptyString {
            let allWorkspaces = dataProvider.fetchWorkspaces(thread: .main)
            
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
            let selectedWorksapce = dataProvider.fetchWorkspace(thread: .main, id: UserDefaults.selectedWorkspaceId)
            
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
    
    func deleteTask(task: TaskBusinessModel) {
        taskCreator.removeBoard(task: task) { [weak self] in guard let self = self else { return }
            let board = self.dataProvider.fetchCurrentBoardWithRemoteIdOnBackgroundThread(id: "\(task.ownerBoardId)")
            self.events.send(.taskJustEditedLocally(board: board))
        }
    }
    
    func editCurrentTask(task: TaskBusinessModel) {
        taskCreator.editTask(task: task) { [weak self] in guard let self = self else { return }
            let board = self.dataProvider.fetchCurrentBoardWithRemoteIdOnBackgroundThread(id: "\(task.ownerBoardId)")
            self.events.send(.taskJustEditedLocally(board: board))
        }
    }
    
    func createNewTask(task: TaskBusinessModel) {
        taskCreator.createNewTask(task: task) { [weak self] in guard let self = self else { return }
            let board = self.dataProvider.fetchCurrentBoardWithRemoteIdOnBackgroundThread(id: "\(task.ownerBoardId)")
            self.events.send(.taskJustCreatedLocally(board: board))
        }
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
    
    @objc private func taskDidCreatedAndSyncedWithServer() {
        fetchCurrentWorkspace()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("CloudSyncDidFinish") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("NewWorkspaceDidSwitched") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("BoardDidCreatedAndSyncedWithServer") , object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("TaskDidCreatedAndSyncedWithServer") , object: nil)
    }
    
}
