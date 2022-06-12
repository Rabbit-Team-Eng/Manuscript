//
//  CloudSync.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import Foundation
import Combine

final class CloudSync {
    
    private var tokens: Set<AnyCancellable> = []
    private let workspaceService: WorkspaceService
    private let boardsService: BoardService
    private let workspaceSyncronizer: WorkspaceSyncronizer
    private let boardSyncronizer: BoardSyncronizer
    private let dataProvider: DataProvider

    init(workspaceService: WorkspaceService, boardsService: BoardService, workspaceSyncronizer: WorkspaceSyncronizer, dataProvider: DataProvider, boardSyncronizer: BoardSyncronizer) {
        self.workspaceService = workspaceService
        self.boardsService = boardsService
        self.workspaceSyncronizer = workspaceSyncronizer
        self.dataProvider = dataProvider
        self.boardSyncronizer = boardSyncronizer
    }
    
    func syncronize() {
        
        let group = DispatchGroup()

        workspaceService.getAllWorkspacesAsBusinessObjects()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in } receiveValue: { [weak self] allWorkspaces in guard let self = self else { return }
                
                let currentWorkspaces = self.dataProvider.fethAllWorkspacesOnBackgroundThread()
                let workspacesDiff = WorkspaceComparator.compare(responseCollection: allWorkspaces, cachedCollection: currentWorkspaces)
                
                group.enter()
                self.workspaceSyncronizer.syncronize(items: workspacesDiff) {
                    group.leave()
                }
                
                let currentBoards = self.dataProvider.fethAllBoardsOnBackgroundThread()
                let boardsServer = allWorkspaces.compactMap { $0.boards }.flatMap { $0 }
                let boardsDiff = BoardComparator.compare(responseCollection: boardsServer, cachedCollection: currentBoards)
                
                group.enter()
                self.boardSyncronizer.syncronize(items: boardsDiff) {
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    NotificationCenter.default.post(name: Notification.Name("CloudSyncDidFinish"), object: nil)
                }

        }
        .store(in: &tokens)
    }
    

}
