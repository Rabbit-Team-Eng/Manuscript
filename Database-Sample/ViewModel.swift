//
//  ViewModel.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/9/22.
//

import Combine
import CoreData

enum ViewModelEvent {
    case didSignedIn(token: String)
    case didRefreshedTheDB
}

class ViewModel {
    
    private let coreDataStack: CoreDataStack
    private let workspaceService: WorkspaceService
    private let boardsService: BoardService
    private let authenticationManager: AuthenticationManager
    private let dataProvider: DataProvider
    private let workspaceSyncronizer: WorkspaceSyncronizer
    private let boardsSyncronizer: BoardSyncronizer
    private let startupUtils: StartupUtils

    public let state: PassthroughSubject<ViewModelEvent, Never> = PassthroughSubject()

    private var tokens: Set<AnyCancellable> = []
    
    init(coreDataStack: CoreDataStack, workspaceService: WorkspaceService, boardsService: BoardService,
         dataProvider: DataProvider, authenticationManager: AuthenticationManager, boardsSyncronizer: BoardSyncronizer,
         workspaceSyncronizer: WorkspaceSyncronizer, startupUtils: StartupUtils) {
        self.coreDataStack = coreDataStack
        self.workspaceService = workspaceService
        self.dataProvider = dataProvider
        self.authenticationManager = authenticationManager
        self.workspaceSyncronizer = workspaceSyncronizer
        self.startupUtils = startupUtils
        self.boardsService = boardsService
        self.boardsSyncronizer = boardsSyncronizer
    }
    
    func signIn(email: String, password: String) {
        authenticationManager.signIn(email: email, password: password)
                .sink(receiveCompletion: { completion in }, receiveValue: { [weak self] accessTokenResponse in
                    guard let self = self else { return }
                    self.state.send(.didSignedIn(token: accessTokenResponse.access_token))
                })
                .store(in: &tokens)
    }
    
    func syncDatabaseInBackground() {
//        Publishers.Zip(workspaceService.getAllWorkspacesAsBusinessObjects(), boardsService.getAllBoardsBusinessModel())
//            .receive(on: DispatchQueue.global(qos: .userInitiated))
//            .sink { completion in } receiveValue: { [weak self] (worskapcesServer, boardsServer) in
//                guard let self = self else { return }
//
//                let currentWorkspaces = self.dataProvider.getAllWorkspacesAsyncBlock()
//                let workspacesDiff = WorkspaceComparator.compare(responseCollection: worskapcesServer, cachedCollection: currentWorkspaces)
//
//                self.workspaceSyncronizer.syncronize(items: workspacesDiff, completion: {
//                    self.state.send(.didRefreshedTheDB)
//                })
//
//                let allBoardsCached = self.dataProvider.getAllBoardsAsyncBlock()
//                let boardsDiff = BoardComparator.compare(responseCollection: boardsServer, cachedCollection: allBoardsCached)
//                self.boardsSyncronizer.syncronize(items: boardsDiff, completion: {
//
//                })
//
//            }
//            .store(in: &tokens)
    }
    
    func printAllLocalDB() {
        let currentWorkspaces = self.dataProvider.fetchAllWorkspacesOnMainThread()
        currentWorkspaces.forEach { workspace in
            print("Local Item: \(workspace.title), id: \(workspace.remoteId)")
        }

    }
    
    func removeLocalDB() {
        let context = coreDataStack.databaseContainer.newBackgroundContext()

        context.automaticallyMergesChangesFromParent = true
 
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WorkspaceEntity")
        let fetchBoards = NSFetchRequest<NSFetchRequestResult>(entityName: "BoardEntity")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let requestBoard = NSBatchDeleteRequest(fetchRequest: fetchBoards)
        context.performAndWait {
            do {
                let result = try context.execute(request)
                let resultBoards = try context.execute(requestBoard)
            } catch {
                fatalError("Failed to execute request: \(error)")
            }
        }
       
    }
    
    func getAllBoards() {
        let boards = dataProvider.fetchAllBoardsOnMainThread()
        boards.forEach { board in
            print("Local | Board: \(board.title)")
        }
    }
    
    func insertIntoLocal() {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            let workspaceCoreDataEntity = WorkspaceEntity(context: context)
            workspaceCoreDataEntity.remoteId = -999
            workspaceCoreDataEntity.title = "\(RandomWordGenerator.shared.getWord().word) \(RandomWordGenerator.shared.getWord().word)"
            workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: Date())
            workspaceCoreDataEntity.isInitiallySynced = false
            workspaceCoreDataEntity.isPendingDeletionOnTheServer = false
            workspaceCoreDataEntity.mainDescription = ""
            workspaceCoreDataEntity.sharingEnabled = false
            do {
                try context.save()
            } catch {
                fatalError()
            }
        
        }
        print("New workspace did inserted into local DB!")

        
    }
    
    func insertIntoServer() {
        workspaceService.createNewWorkspace(requestBody: WorkspaceRequest(title: "\(RandomWordGenerator.shared.getWord().word) \(RandomWordGenerator.shared.getWord().word)",
                                                                             description: "" ,
                                               shareEnabled: false))
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .sink { completion in } receiveValue: { workspaceResponse in
            print("New workspace was created in the server!")
        }
        .store(in: &tokens)
    }
    
    
}
