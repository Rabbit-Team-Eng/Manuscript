//
//  MainViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/22/22.
//

import Combine
import UIKit
import CoreData

enum UIEvent {
    case newBoardDidCreated
    case selectedWorkspaceDidChanged
    case existingBoardDidUpdated
    case existingBoardDidDeleted
}

class MainViewModel {
    
    private let repository: Repository
    
    var selectedWorkspacePublisher: PassthroughSubject<WorkspaceBusinessModel, Never> = PassthroughSubject()
    var workspacesPublisher: PassthroughSubject<[WorkspaceBusinessModel], Never> = PassthroughSubject()

    var uiEvent: PassthroughSubject<UIEvent, Never> = PassthroughSubject()
    
    var workspaces: [WorkspaceBusinessModel]?
    var selectedWorkspace: WorkspaceBusinessModel?
    var selectedBoard: BoardBusinessModel?

    var tokens: Set<AnyCancellable> = []
    
    init(repository: Repository) {
        self.repository = repository
        self.startListenningToWorkspaceDatabaseEvent()
    }
    
    func fetchLocalDatabase() {
        repository.fetchLocalDatabase()
    }
    
    func selectNewWorkspace(id: String) {
        if let workspaces = workspaces, let newlySelectedWorkspace = workspaces.first(where: { "\($0.remoteId)" == id }) {
            UserDefaults.selectedWorkspaceId = id
            selectedWorkspace = newlySelectedWorkspace
            uiEvent.send(.selectedWorkspaceDidChanged)
        }
    }
    
    func createBoard(title: String, asset: String) {
        guard let ownerWorkspaceCoreDataId = selectedWorkspace?.coreDataId else { return }
        let boardRequest = BoardCreateCoreDataRequest(ownerWorkspaceCoreDataId: ownerWorkspaceCoreDataId, title: title, assetUrl: asset)
        
        repository.createBoard(board: boardRequest) { [weak self] in guard let self = self else { return }
            self.uiEvent.send(.newBoardDidCreated)
        }
    }
    
    func editBoard(id: Int64, coreDataId: NSManagedObjectID, title: String, asset: String) {
        let board = BoardEditCoreDataRequest(id: id, coreDataId: coreDataId, title: title, assetUrl: asset)
        
        repository.editBoard(board: board) { [weak self] in guard let self = self else { return }
            self.uiEvent.send(.existingBoardDidUpdated)
        }
    }
    
    func removeBoard(id: Int64, coreDataId: NSManagedObjectID) {
        let board = BoardDeleteCoreDataRequest(id: id, coreDataId: coreDataId)
        
        repository.removeBoard(board: board) { [weak self] in guard let self = self else { return }
            self.uiEvent.send(.existingBoardDidDeleted)
        }
    }
    
    func syncTheCloud() {
        repository.refreshDatabase()
    }
    
    private func startListenningToWorkspaceDatabaseEvent() {
        
        repository.worskpacesPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] workspaces in guard let self = self else { return }
                
                self.workspaces = workspaces
                self.workspacesPublisher.send(workspaces)
                
        }
        .store(in: &tokens)
        
        repository.selectedWorskpacesPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] selectedWorkspace in guard let self = self else { return }
                
                self.selectedWorkspace = selectedWorkspace
                
                if let updatedBoard = selectedWorkspace.boards?.first(where: { $0.remoteId == self.selectedBoard?.remoteId }) { self.selectedBoard = updatedBoard }
                
                self.selectedWorkspacePublisher.send(selectedWorkspace)
                
        }
        .store(in: &tokens)

    }
    
}
