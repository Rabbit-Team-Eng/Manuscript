//
//  MainViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/22/22.
//

import Combine
import UIKit
import CoreData

enum BoardsViewControllerUIEvent {
    case newBoardDidCreated
    case selectedWorkspaceDidChanged
    case existingBoardDidUpdated
    case existingBoardDidDeleted
    case newTaskDidCreated
}

protocol BoardsViewModelProtocol {
    
    func selectNewWorkspace(id: String)
    
    func createBoardForSelectedWorkspace(title: String, asset: String)
    
    func editBoardForSelectedWorkspace(id: Int64, coreDataId: NSManagedObjectID, title: String, asset: String)
    
    func removeBoardForSelectedWorkspace(id: Int64, coreDataId: NSManagedObjectID)
        
    func fetchLocalDatabaseAndNotifyAllSubscribers()
    
    func syncTheCloud()

}

class BoardsViewModel: BoardsViewModelProtocol {
    
    private let repository: Repository
    
    var selectedWorkspacePublisher: PassthroughSubject<WorkspaceBusinessModel, Never> = PassthroughSubject()
    var workspacesPublisher: PassthroughSubject<[WorkspaceBusinessModel], Never> = PassthroughSubject()

    var boardsViewControllerUIEvent: PassthroughSubject<BoardsViewControllerUIEvent, Never> = PassthroughSubject()

    var workspaces: [WorkspaceBusinessModel]?
    var selectedWorkspace: WorkspaceBusinessModel?
    var selectedBoard: BoardBusinessModel?

    var tokens: Set<AnyCancellable> = []
    
    init(repository: Repository) {
        self.repository = repository
        self.startListenningToWorkspaceDatabaseEvent()
    }
    
    func fetchLocalDatabaseAndNotifyAllSubscribers() {
        repository.fetchLocalDatabase()
    }
    
    func selectNewWorkspace(id: String) {
        if let workspaces = workspaces, let newlySelectedWorkspace = workspaces.first(where: { "\($0.remoteId)" == id }) {
            UserDefaults.selectedWorkspaceId = id
            selectedWorkspace = newlySelectedWorkspace
            boardsViewControllerUIEvent.send(.selectedWorkspaceDidChanged)
        }
    }
    
    func createTaskForBoard(title: String, description: String, doeDate: String, ownerBoardId: Int64, status: String, priority: String, assigneeUserId: String) {
        if let updatedBoard = selectedWorkspace?.boards?.first(where: { $0.remoteId == ownerBoardId }) { self.selectedBoard = updatedBoard }
        
        repository.createTask(task: TaskCreateCoreDataRequest(title: title,
                                                              description: description,
                                                              doeDate: doeDate,
                                                              ownerBoardId: ownerBoardId,
                                                              status: status,
                                                              priority: priority,
                                                              assigneeUserId: assigneeUserId)) {  [weak self] in guard let self = self else { return }
            self.boardsViewControllerUIEvent.send(.newTaskDidCreated)

            
        }
        
    }
    
    func createBoardForSelectedWorkspace(title: String, asset: String) {
        guard let ownerWorkspaceCoreDataId = selectedWorkspace?.coreDataId else { return }
        let boardRequest = BoardCreateCoreDataRequest(ownerWorkspaceCoreDataId: ownerWorkspaceCoreDataId, title: title, assetUrl: asset)
        
        repository.createBoard(board: boardRequest) { [weak self] in guard let self = self else { return }
            self.boardsViewControllerUIEvent.send(.newBoardDidCreated)
        }
    }
    
    func editBoardForSelectedWorkspace(id: Int64, coreDataId: NSManagedObjectID, title: String, asset: String) {
        let board = BoardEditCoreDataRequest(id: id, coreDataId: coreDataId, title: title, assetUrl: asset)
        
        repository.editBoard(board: board) { [weak self] in guard let self = self else { return }
            self.boardsViewControllerUIEvent.send(.existingBoardDidUpdated)
        }
    }
    
    func removeBoardForSelectedWorkspace(id: Int64, coreDataId: NSManagedObjectID) {
        let board = BoardDeleteCoreDataRequest(id: id, coreDataId: coreDataId)
        
        repository.removeBoard(board: board) { [weak self] in guard let self = self else { return }
            self.boardsViewControllerUIEvent.send(.existingBoardDidDeleted)
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
