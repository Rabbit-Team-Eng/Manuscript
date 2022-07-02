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
    private let taskSyncronizer: TaskSyncronizer
    private let dataProvider: DataProvider
    private let membersCoreDataManager: MemberCoreDataManager

    init(workspaceService: WorkspaceService, boardsService: BoardService, membersCoreDataManager: MemberCoreDataManager, workspaceSyncronizer: WorkspaceSyncronizer, dataProvider: DataProvider, boardSyncronizer: BoardSyncronizer, taskSyncronizer: TaskSyncronizer) {
        self.workspaceService = workspaceService
        self.membersCoreDataManager = membersCoreDataManager
        self.boardsService = boardsService
        self.workspaceSyncronizer = workspaceSyncronizer
        self.dataProvider = dataProvider
        self.boardSyncronizer = boardSyncronizer
        self.taskSyncronizer = taskSyncronizer
    }
    
    func syncronize(completion: @escaping () -> Void) {
        
        workspaceService.getAllWorkspacesAsBusinessObjects()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in } receiveValue: { [weak self] allWorkspaces in guard let self = self else { return }
                
                let dispatchers = DispatchGroup()
                
                let currentWorkspaces = self.dataProvider.fetchWorkspaces(thread: .background)
                let workspacesDiff = WorkspaceComparator.compare(responseCollection: allWorkspaces, cachedCollection: currentWorkspaces)
                
                dispatchers.enter()
                self.workspaceSyncronizer.syncronize(items: workspacesDiff) {
                    dispatchers.leave()
                }
                
                let currentBoards = self.dataProvider.fethAllBoardsOnBackgroundThread()
                let boardsServer = allWorkspaces.compactMap { $0.boards }.flatMap { $0 }
                let boardsDiff = BoardComparator.compare(responseCollection: boardsServer, cachedCollection: currentBoards)
                
                dispatchers.enter()
                self.boardSyncronizer.syncronize(items: boardsDiff) {
                    dispatchers.leave()
                }
                
                let currentTasks = self.dataProvider.fethAllTasksOnBackgroundThread()
                let serverTasks = boardsServer.compactMap { $0.tasks }.flatMap { $0 }
                let tasksDiff = TaskComparator.compare(responseCollection: serverTasks, cachedCollection: currentTasks)
                
                dispatchers.enter()
                self.taskSyncronizer.syncronize(items: tasksDiff) {
                    dispatchers.leave()
                }
                
                let allMembersFromDifferentWorkspaces = allWorkspaces.compactMap { $0.members }.flatMap { $0 }
                self.membersCoreDataManager.insertNewMembers(latestMembers: allMembersFromDifferentWorkspaces)
                
                dispatchers.notify(queue: .global(qos: .userInitiated)) {
                    completion()
                }

        }
        .store(in: &tokens)
    }
    

}
