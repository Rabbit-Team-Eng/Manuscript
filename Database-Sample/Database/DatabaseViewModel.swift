//
//  DatabaseViewModel.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Combine
import UIKit

enum DatabaseViewModelState {
    case didInsertedNewWorkspaceIntoDatabase
    case didFetchWorkspaceById(workspace: WorkspaceBusinessModel)
}

class DatabaseViewModel {
    
    private let workspaceCoreDataManager: WorkspaceCoreDataManager
    private var tokens: Set<AnyCancellable> = []
    
    public let state: PassthroughSubject<DatabaseViewModelState, Never> = PassthroughSubject()
    
    init(workspaceCoreDataManager: WorkspaceCoreDataManager) {
        self.workspaceCoreDataManager = workspaceCoreDataManager
    }
    
    func insertNewWorkspacesIntoLocalDatabase() {
        
        let item = WorkspaceBusinessModel(remoteId: -999,
                                          title: "\(RandomWordGenerator.shared.getWord().word) \(RandomWordGenerator.shared.getWord().word) Workspace",
                                          sharingEnabled: false,
                                          lastModifiedDate: DateTimeUtils.convertDateToServerString(date: Date()),
                                          isInitiallySynced: false,
                                          isPendingDeletionOnTheServer: false)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.workspaceCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
            self.state.send(.didInsertedNewWorkspaceIntoDatabase)
        }

    }
    
    func fetchWorkspaceById(id: Int) {
//        let wc = workspaceCoreDataManager.getWorkspaceByIdSync(id: id)
//        let x =
//        state.send(.didFetchWorkspaceById(workspace: wc!))
    }
}
