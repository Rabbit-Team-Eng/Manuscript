//
//  MainViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/22/22.
//

import Combine
import UIKit

enum MainViewModelEvent {
    case newBoardDidCreated
    case newWorkspaceDidSelected
}

class MainViewModel {
    
    private let repository: WorkspaceRepository
    
    var selectedWorkspacePublisher: PassthroughSubject<WorkspaceBusinessModel, Never> = PassthroughSubject()
    var workspacesPublisher: PassthroughSubject<[WorkspaceBusinessModel], Never> = PassthroughSubject()

    var event: PassthroughSubject<MainViewModelEvent, Never> = PassthroughSubject()

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
        event.send(.newWorkspaceDidSelected)
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
    
    func editBoard(board: BoardBusinessModel) {
        repository.editBoard(board: board)
    }
    
    private func startListenningToWorkspaceDatabaseEvent() {
        selectedWorkspacePublisher = repository.selectedWorskpacesPublisher
        workspacesPublisher = repository.worskpacesPublisher
    }
    
}
