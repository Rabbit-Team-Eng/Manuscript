//
//  WorkspaceRepository.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/21/22.
//

import Combine
import Foundation

class Repository {
    
    var worskpacesPublisher: PassthroughSubject<[WorkspaceBusinessModel], Never> = PassthroughSubject()
    var selectedWorskpacesPublisher: PassthroughSubject<WorkspaceBusinessModel, Never> = PassthroughSubject()

    private let cloudSync: CloudSync
    private let dataProvider: DataProvider
    private let boardCreator: BoardCreator
    private let taskCreator: TaskCreator
    private let signalRManager: SignalRManager
    
    private var tokens: Set<AnyCancellable> = []

    init(cloudSync: CloudSync, dataProvider: DataProvider, boardCreator: BoardCreator, taskCreator: TaskCreator, signalRManager: SignalRManager) {
        self.cloudSync = cloudSync
        self.dataProvider = dataProvider
        self.boardCreator = boardCreator
        self.taskCreator = taskCreator
        self.signalRManager = signalRManager
        self.refreshDatabase()
        self.initializeSocketListeners()
    }
    
    private func initializeSocketListeners() {
        signalRManager.workspaceEntitiesDidChangePublisher.sink { [weak self] event in guard let self = self else { return }
            if case .board = event { self.refreshDatabase() }
        }
        .store(in: &tokens)
    }
    
    func refreshDatabase() {
        cloudSync.syncronize() { [weak self] in guard let self = self else { return }
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
        }
    }
    
    func createBoard(board: BoardBusinessModel, localCompletion: @escaping () -> Void) {
        boardCreator.createBoard(board: board) { [weak self] in guard let self = self else { return }
            
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
            localCompletion()
            
        } serverCompletion: { [weak self] in guard let self = self else { return }
            
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            
            if let currentWorkspaces = allWorkspacesAfterSync.first(where: { "\($0.remoteId)" == UserDefaults.selectedWorkspaceId }),
               let currentMembers = currentWorkspaces.members?.filter({ $0.remoteId != UserDefaults.userId }) {
                
                self.signalRManager.notifyMembers(signalREvent: .board, toMembers: currentMembers) { [weak self] signalRCompletionEvent in guard let self = self else { return }
                    if case .error(let errorDescription) = signalRCompletionEvent { print("SignalR: \(board.title) board did fail broadcasted: \(errorDescription)")  }
                    if case .success = signalRCompletionEvent { print("SignalR: \(board.title) board did successfully broadcasted!") }
                    self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
                }
                
            }
        }

    }
    
    func editBoard(board: BoardBusinessModel, localCompletion: @escaping () -> Void) {
        boardCreator.editBoard(board: board) { [weak self] in guard let self = self else { return }
            
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
            localCompletion()
            
        } serverCompletion: { [weak self] in guard let self = self else { return }
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            
            if let currentWorkspaces = allWorkspacesAfterSync.first(where: { "\($0.remoteId)" == UserDefaults.selectedWorkspaceId }),
               let currentMembers = currentWorkspaces.members?.filter({ $0.remoteId != UserDefaults.userId }) {
                
                self.signalRManager.notifyMembers(signalREvent: .board, toMembers: currentMembers) { [weak self] signalRCompletionEvent in guard let self = self else { return }
                    if case .error(let errorDescription) = signalRCompletionEvent { print("SignalR: \(board.title) board did fail broadcasted: \(errorDescription)")  }
                    if case .success = signalRCompletionEvent { print("SignalR: \(board.title) board did successfully broadcasted!") }
                    self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
                }
            }
        }
    }
    
    func removeBoard(board: BoardBusinessModel, localCompletion: @escaping () -> Void) {

        boardCreator.removeBoard(board: board) { [weak self] in guard let self = self else { return }
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
            localCompletion()
        } serverCompletion: { [weak self] in guard let self = self else { return }
            let allWorkspacesAfterSync = self.dataProvider.fetchWorkspaces(thread: .background)
            
            if let currentWorkspaces = allWorkspacesAfterSync.first(where: { "\($0.remoteId)" == UserDefaults.selectedWorkspaceId }),
               let currentMembers = currentWorkspaces.members?.filter({ $0.remoteId != UserDefaults.userId }) {
                
                self.signalRManager.notifyMembers(signalREvent: .board, toMembers: currentMembers) { [weak self] signalRCompletionEvent in guard let self = self else { return }
                    if case .error(let errorDescription) = signalRCompletionEvent { print("SignalR: \(board.title) board did fail broadcasted: \(errorDescription)")  }
                    if case .success = signalRCompletionEvent { print("SignalR: \(board.title) board did successfully broadcasted!") }
                    self.notifyDataSetChanged(workspaces: allWorkspacesAfterSync)
                }
            }
        }

    }
    
    func fetchLocalDatabase() {
        let allWorkspacesInitiallyBeforeSync = self.dataProvider.fetchWorkspaces(thread: .background)
        notifyDataSetChanged(workspaces: allWorkspacesInitiallyBeforeSync)
    }
    
    private func notifyDataSetChanged(workspaces: [WorkspaceBusinessModel]) {
        
        if UserDefaults.selectedWorkspaceId == "" {
            if let firstWorkspaceRemoteId = workspaces.first?.remoteId {
                UserDefaults.selectedWorkspaceId = "\(firstWorkspaceRemoteId)"
            }
        }
        
        if let selectedWorkspace = workspaces.first(where: { "\($0.remoteId)" == UserDefaults.selectedWorkspaceId }) {
            self.worskpacesPublisher.send(workspaces)
            self.selectedWorskpacesPublisher.send(selectedWorkspace)
        }
    }
}
