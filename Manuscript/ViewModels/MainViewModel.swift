//
//  MainViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/22/22.
//

import Combine
import UIKit
import CoreData

enum MainViewModelEvent {
    case newBoardDidCreated
    case newWorkspaceDidSelected
    case existingBoardDidSelected(board: BoardBusinessModel)
    case existingBoardDidUpdated
    case existingBoardDidDeleted
}

class MainViewModel {
    
    private let repository: WorkspaceRepository
    
    var selectedWorkspacePublisher: PassthroughSubject<WorkspaceBusinessModel, Never> = PassthroughSubject()
    var workspacesPublisher: PassthroughSubject<[WorkspaceBusinessModel], Never> = PassthroughSubject()

    var event: PassthroughSubject<MainViewModelEvent, Never> = PassthroughSubject()
    
    var selectedWorkspace: WorkspaceBusinessModel?

    var tokens: Set<AnyCancellable> = []
    
    init(repository: WorkspaceRepository) {
        self.repository = repository
        self.startListenningToWorkspaceDatabaseEvent()
    }
    
    func fetchLocalDatabase() {
        repository.fetchLocalDatabase()
    }
    
    func selectNewWorkspace(id: String) {
        UserDefaults.selectedWorkspaceId = id
        fetchLocalDatabase()
        event.send(.newWorkspaceDidSelected)
    }
    
    func fetchCurrentlySelectedBoard(id: Int64) {
        repository.fetchBoardById(id: id)
    }
    
    func createBoard(title: String, asset: String) {
        let board = BoardBusinessModel(remoteId: 0,
                                       title: title,
                                       detailDescription: "",
                                       assetUrl: asset,
                                       ownerWorkspaceId: Int64(UserDefaults.selectedWorkspaceId)!,
                                       lastModifiedDate: DateTimeUtils.convertDateToServerString(date: .now),
                                       isInitiallySynced: false,
                                       isPendingDeletionOnTheServer: false)
        
        repository.createBoard(board: board) { [weak self] in guard let self = self else { return }
            self.event.send(.newBoardDidCreated)
        }
    }
    
    func editBoard(id: Int64, coreDataId: NSManagedObjectID, title: String, asset: String) {
        let board = BoardBusinessModel(remoteId: id,
                                       coreDataId: coreDataId,
                                       title: title,
                                       detailDescription: "",
                                       assetUrl: asset,
                                       ownerWorkspaceId: Int64(UserDefaults.selectedWorkspaceId)!,
                                       lastModifiedDate: DateTimeUtils.convertDateToServerString(date: .now),
                                       isInitiallySynced: true,
                                       isPendingDeletionOnTheServer: false)
        
        repository.editBoard(board: board) { [weak self] in guard let self = self else { return }
            self.event.send(.existingBoardDidUpdated)
        }
    }
    
    func removeBoard(id: Int64, coreDataId: NSManagedObjectID) {
        let board = BoardBusinessModel(remoteId: id,
                                       coreDataId: coreDataId,
                                       title: "title",
                                       detailDescription: "",
                                       assetUrl: "asset",
                                       ownerWorkspaceId: Int64(UserDefaults.selectedWorkspaceId)!,
                                       lastModifiedDate: DateTimeUtils.convertDateToServerString(date: .now),
                                       isInitiallySynced: true,
                                       isPendingDeletionOnTheServer: false)
        
        repository.removeBoard(board: board) { [weak self] in guard let self = self else { return }
            self.event.send(.existingBoardDidDeleted)
        }
    }
    
    func syncTheCloud() {
        repository.refreshDatabase()
    }
    
    private func startListenningToWorkspaceDatabaseEvent() {
        workspacesPublisher = repository.worskpacesPublisher
        
        repository.selectedWorskpacesPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] selectedWorkspace in guard let self = self else { return }
                
                self.selectedWorkspacePublisher.send(selectedWorkspace)
                self.selectedWorkspace = selectedWorkspace
                
        }
        .store(in: &tokens)

        repository.selectedBoardPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] boardBusinessModel in guard let self = self else { return }
                
                self.event.send(.existingBoardDidSelected(board: boardBusinessModel))
        }
        .store(in: &tokens)
    }
    
}
