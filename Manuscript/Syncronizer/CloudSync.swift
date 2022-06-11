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
        Publishers.Zip(workspaceService.getAllWorkspacesAsBusinessObjects(), boardsService.getAllBoardsBusinessModel())
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in } receiveValue: { [weak self] (worskapcesServer, boardsServer) in guard let self = self else { return }
                
                let currentWorkspaces = self.dataProvider.fethAllWorkspacesOnBackgroundThread()
                let workspacesDiff = WorkspaceComparator.compare(responseCollection: worskapcesServer, cachedCollection: currentWorkspaces)
                
                self.workspaceSyncronizer.syncronize(items: workspacesDiff, completion: { [weak self] in
                    guard let self = self else { return }
                    
                    let currentBoards = self.dataProvider.fethAllBoardsOnBackgroundThread()
                    let boardsDiff = BoardComparator.compare(responseCollection: boardsServer, cachedCollection: currentBoards)
                    self.boardSyncronizer.syncronize(items: boardsDiff) { [weak self] in
                        guard let self = self else { return }
                        
                        
                        self.notify()
                    }
                })
            }
            .store(in: &tokens)
    }
    
    private func notify() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("CloudSyncDidFinish"), object: nil)
        }
    }
}
